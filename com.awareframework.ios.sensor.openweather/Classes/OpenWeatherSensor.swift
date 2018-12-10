//
//  OpenWeatherSensor.swift
//  com.awareframework.ios.sensor.openweather
//
//  Created by Yuuki Nishiyama on 2018/11/18.
//

import UIKit
import Foundation
import SwiftyJSON
import CoreLocation
import com_awareframework_ios_sensor_core
import com_awareframework_ios_sensor_locations

extension Notification.Name {
    public static let actionAwareOpenWeather      = Notification.Name(OpenWeatherSensor.ACTION_AWARE_OPENWEATHER)
    public static let actionAwareOpenWeatherStart = Notification.Name(OpenWeatherSensor.ACTION_AWARE_OPENWEATHER_START)
    public static let actionAwareOpenWeatherStop  = Notification.Name(OpenWeatherSensor.ACTION_AWARE_OPENWEATHER_STOP)
    public static let actionAwareOpenWeatherSync  = Notification.Name(OpenWeatherSensor.ACTION_AWARE_OPENWEATHER_SYNC)
    public static let actionAwareOpenWeatherSetLabel  = Notification.Name(OpenWeatherSensor.ACTION_AWARE_OPENWEATHER_SET_LABEL)
    public static let actionAwareOpenWeatherSyncCompletion  = Notification.Name(OpenWeatherSensor.ACTION_AWARE_OPEN_WEATHER_SYNC_COMPLETION)
    
}

extension OpenWeatherSensor{
    public static let ACTION_AWARE_OPENWEATHER       = "com.awareframework.ios.sensor.openweather"
    public static let ACTION_AWARE_OPENWEATHER_START = "com.awareframework.ios.sensor.openweather.ACTION_AWARE_OPENWEATHER_START"
    public static let ACTION_AWARE_OPENWEATHER_STOP  = "com.awareframework.ios.sensor.openweather.ACTION_AWARE_OPENWEATHER_STOP"
    public static let ACTION_AWARE_OPENWEATHER_SYNC  = "com.awareframework.ios.sensor.openweather.ACTION_AWARE_OPENWEATHER_SYNC"
    public static let ACTION_AWARE_OPENWEATHER_SET_LABEL = "com.awareframework.ios.sensor.openweather.ACTION_AWARE_OPENWEATHER_SET_LABEL"
    public static var EXTRA_LABEL  = "label"
    public static let TAG = "com.awareframework.ios.sensor.openweather"
    
    public static let ACTION_AWARE_OPEN_WEATHER_SYNC_COMPLETION = "com.awareframework.ios.sensor.openweather.SENSOR_SYNC_COMPLETION"
    public static let EXTRA_STATUS = "status"
    public static let EXTRA_ERROR = "error"

}

public protocol OpenWeatherObserver {
    func onDataChanged(data:OpenWeatherData)
}

public class OpenWeatherSensor: AwareSensor, LocationsObserver {
    
    public var CONFIG:Config = Config()
    var locationSensor:LocationsSensor?
    var openWeatherApi:OpenWeatherApi?

    public class Config:SensorConfig {
        
        public var sensorObserver:OpenWeatherObserver?
        public var interval:Int = 15 // min
        {
            didSet{
                if self.interval < 1 {
                    print("[OpenWeatherSensor][Illegal Parameter] The 'interval' value has to be gratter than 0.",
                          "This parameter ('\(self.interval)') is ignored.")
                    self.interval = oldValue
                }
            }
        }
        
        public var apiKey:String?    // http://openweathermap.org/
        public var unit = "metric"   // metric or imperial
        {
            didSet{
                if self.unit == "metric" || self.unit == "imperial" {
                    // ok
                }else{
                    print("[OpenWeatherSensor][Illegal Parameter] You can set 'metric' or 'imperial' as the unit.",
                          "This parameter ('\(self.unit)') is ignored.")
                    self.unit = oldValue
                }
            }
        }
        
        public override init() {}
        
        public override func set(config: Dictionary<String, Any>) {
            super.set(config: config)
            
            if let intervalMin = config["interval"] as? Int {
                self.interval = intervalMin
            }
            
            if let api = config["apiKey"] as? String {
                self.apiKey = api
            }
            
            if let unit = config["unit"] as? String {
                if unit == "metric" {
                    self.unit = unit
                }else if unit == "imperial" {
                    self.unit = unit
                }
            }
        }
        
        public func apply(closure: (_ config: OpenWeatherSensor.Config ) -> Void) -> Self {
            closure(self)
            return self
        }
    }
    
    public override convenience init() {
        self.init(OpenWeatherSensor.Config())
    }
    
    public func onLocationChanged(data location: LocationsData) {
        
        guard self.CONFIG.apiKey != nil else {
            if self.CONFIG.debug {
                print(OpenWeatherSensor.TAG, "API Key is null. Please get an API Key from http://openweathermap.org/")
            }
            return
        }
        
        self.openWeatherApi = OpenWeatherApi.init(longitude: location.longitude,
                                                  latitude:  location.latitude,
                                                  config: self.CONFIG)
        self.openWeatherApi?.getWeatherData(completionHandler: { data in
            do {
                let json = try JSON.init(data: data)
                let weatherData = OpenWeatherData()
                if let obj = json.dictionaryObject{
                    weatherData.setValuesForKeys(obj)
                    weatherData.unit = self.CONFIG.unit
                    weatherData.label = self.CONFIG.label
                    if let engine = self.dbEngine {
                        engine.save(weatherData)
                    }
                    if let observer = self.CONFIG.sensorObserver {
                        observer.onDataChanged(data: weatherData)
                    }
                    self.notificationCenter.post(name: .actionAwareOpenWeather, object: self)
                }
            } catch {
                if self.CONFIG.debug { print(error) }
            }
        })
    }
    public func onExitRegion(data: GeofenceData) {
        
    }
    
    public func onEnterRegion(data: GeofenceData) {
        
    }
    
    public func onVisit(data: VisitData) {
        
    }
    
    
    public init(_ config:OpenWeatherSensor.Config) {
        super.init()
        self.CONFIG = config
        self.initializeDbEngine(config: config)
        if config.debug { print(OpenWeatherSensor.TAG,"OpenWeather sensor is created.") }
    }
    
    public override func start() {
        if self.locationSensor == nil {
            locationSensor = LocationsSensor.init(LocationsSensor.Config().apply{config in
                config.accuracy = kCLLocationAccuracyThreeKilometers
                config.sensorObserver = self
                config.frequencyGps = Double(self.CONFIG.interval) * 60.0
            })
            locationSensor?.start()
            self.notificationCenter.post(name: .actionAwareOpenWeatherStart, object: self)
        }
    }
    
    public override func stop() {
        if let lSensor = locationSensor{
            lSensor.stop()
            self.locationSensor = nil
            self.notificationCenter.post(name: .actionAwareOpenWeatherStop, object: self)
        }
    }
    
    public override func sync(force: Bool = false) {
        if let engine = self.dbEngine {
            engine.startSync(OpenWeatherData.TABLE_NAME, OpenWeatherData.self, DbSyncConfig.init().apply{config in
                config.debug = self.CONFIG.debug
                config.dispatchQueue = DispatchQueue(label: "com.awareframework.ios.sensor.openweather.sync.queue")
                config.completionHandler = { (status, error) in
                    var userInfo: Dictionary<String,Any> = [OpenWeatherSensor.EXTRA_STATUS :status]
                    if let e = error {
                        userInfo[OpenWeatherSensor.EXTRA_ERROR] = e
                    }
                    self.notificationCenter.post(name: .actionAwareOpenWeatherSyncCompletion ,
                                                 object: self,
                                                 userInfo:userInfo)
                }
            })
            self.notificationCenter.post(name: .actionAwareOpenWeatherSync, object: self)
        }
    }
    
    public override func set(label:String){
        self.CONFIG.label = label
        self.notificationCenter.post(name: .actionAwareOpenWeatherSetLabel,
                                     object: self,
                                     userInfo: [OpenWeatherSensor.EXTRA_LABEL:label])
    }
}

public class OpenWeatherApi: URLSessionDataTask, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    var receivedData:Data = Data()
    var urlSession:URLSession?
    var longitude:Int = 0
    var latitude:Int  = 0
    var apiKey:String = ""
    var unit:String   = ""
    var debug = false
    var complition:((_ result:Data) -> ())? = nil
    
    public init(longitude:Double, latitude:Double, config:OpenWeatherSensor.Config) {
        super.init()
        self.latitude = Int(latitude)
        self.longitude = Int(longitude)
        if let uwApiKey = config.apiKey {
            self.apiKey = uwApiKey
        }
        self.unit = config.unit
        self.debug = config.debug
    }
    
    public func getWeatherData(completionHandler: @escaping (_ result:Data) -> ()){
        
        self.complition = completionHandler
        self.urlSession = {
            let sessionConfig = URLSessionConfiguration.background(withIdentifier: "com.awareframework.ios.sensor.openweather.identifier.getdata")
            sessionConfig.allowsCellularAccess = true
            // sessionConfig.sharedContainerIdentifier = "com.awareframework.ios.sensor.openweather.identifier"
            sessionConfig.timeoutIntervalForRequest = 30
            sessionConfig.timeoutIntervalForResource = 30
            sessionConfig.httpMaximumConnectionsPerHost = 5
            sessionConfig.isDiscretionary = false
            return URLSession(configuration: sessionConfig, delegate: self, delegateQueue: .main)
        }()

        let url = URL.init(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(self.latitude)&lon=\(self.longitude)&appid=\(self.apiKey)&units=\(self.unit)")
        if let unwrappedUrl = url, let session = self.urlSession {
            var request = URLRequest.init(url: unwrappedUrl)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.timeoutInterval = 30
            request.httpMethod = "GET"
            request.allowsCellularAccess = true
            session.getAllTasks { (tasks) in
                for task in tasks {
                    task.cancel()
                }
                let task = session.dataTask(with: request)
                task.resume()
            }
        }
    }

    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response:
        URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // if debug{ print( OpenWeatherSensor.TAG, #function) }
        if let httpResponse = response as? HTTPURLResponse{
            if(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300){
                completionHandler(URLSession.ResponseDisposition.allow);
                if debug{ print( OpenWeatherSensor.TAG, "ResponseDisposition.allow") }
            }else{
                completionHandler(URLSession.ResponseDisposition.cancel);
                if debug{ print( OpenWeatherSensor.TAG, "ResponseDisposition.cancel") }
            }
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        // if debug{ print( OpenWeatherSensor.TAG, print(#function)) }
        if let e = error {
            print(e)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.receivedData.append(data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // if debug{ print( OpenWeatherSensor.TAG, print(#function)) }
        if let unwrappedError = error {
            if debug{ print( OpenWeatherSensor.TAG, "failed: \(unwrappedError)") }
            session.invalidateAndCancel()
        }else{
            session.finishTasksAndInvalidate()
            if let handler = self.complition{
                handler( Data.init(receivedData) )
            }
        }
        receivedData = Data()
    }
    
}
