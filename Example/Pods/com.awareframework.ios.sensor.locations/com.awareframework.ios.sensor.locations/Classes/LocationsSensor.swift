//
//  LocationsSensor.swift
//  com.aware.ios.sensor.core
//
//  Created by Yuuki Nishiyama on 2018/10/22.
//

import UIKit
import com_awareframework_ios_sensor_core
import CoreLocation
import SwiftyJSON

extension Notification.Name {
    public static let actionAwareLocations      = Notification.Name(LocationsSensor.ACTION_AWARE_LOCATIONS)
    public static let actionAwareLocationStart  = Notification.Name(LocationsSensor.ACTION_AWARE_LOCATION_START)
    public static let actionAwareLocationStop   = Notification.Name(LocationsSensor.ACTION_AWARE_LOCATION_STOP)
    public static let actionAwareLocationSync   = Notification.Name(LocationsSensor.ACTION_AWARE_LOCATION_SYNC)
    public static let actionAwareLocationSetLabel  = Notification.Name(LocationsSensor.ACTION_AWARE_LOCATION_SET_LABEL)
}

public protocol LocationsObserver {
    func onLocationChanged(data: LocationsData)
}

public class LocationsSensor: AwareSensor{

    public let locationManager = CLLocationManager()
    
    public var CONFIG:LocationsSensor.Config
    
    public static let TAG = "AWARE::Locations"
    
    var timer:Timer?
    
    public var LAST_DATA:CLLocation?
    
    /**
     * Fired event: New location available
     */
    public static let ACTION_AWARE_LOCATIONS = "ACTION_AWARE_LOCATIONS"
    
    /**
     * Fired event: GPS location is active
     */
    public static let ACTION_AWARE_GPS_LOCATION_ENABLED = "ACTION_AWARE_GPS_LOCATION_ENABLED"
    
    /**
     * Fired event: Network location is active
     */
    public static let ACTION_AWARE_NETWORK_LOCATION_ENABLED = "ACTION_AWARE_NETWORK_LOCATION_ENABLED"
    
    /**
     * Fired event: GPS location disabled
     */
    public static let ACTION_AWARE_GPS_LOCATION_DISABLED = "ACTION_AWARE_GPS_LOCATION_DISABLED"
    
    /**
     * Fired event: Network location disabled
     */
    public static let ACTION_AWARE_NETWORK_LOCATION_DISABLED = "ACTION_AWARE_NETWORK_LOCATION_DISABLED"
    
    public static let ACTION_AWARE_LOCATION_START = "com.awareframework.android.sensor.locations.SENSOR_START"
    public static let ACTION_AWARE_LOCATION_STOP = "com.awareframework.android.sensor.locations.SENSOR_STOP"
    
    public static let ACTION_AWARE_LOCATION_SET_LABEL = "com.awareframework.android.sensor.locations.SET_LABEL"
    public static var EXTRA_LABEL = "label"
    
    public static let ACTION_AWARE_LOCATION_SYNC = "com.awareframework.android.sensor.locations.SENSOR_SYNC"
    
    
    public class Config:SensorConfig {
        
        public var sensorObserver:LocationsObserver?
        // var geoFences: String? = nil;
        public var statusGps = true;
        public var frequencyGps:   Double = 180;
        public var minGpsAccuracy: Double = 150;
        public var expirationTime: Int64  = 300;
        public var saveAll = false;
        public var regions:Array<CLRegion>? = nil
        
        public var accuracy:CLLocationAccuracy? = nil
        
        // iOS does not provide the network based location service
        // var statusNetwork = true;
        // var statusPassive = true;
        // var frequencyNetwork: Int = 300;
        // var minNetworkAccuracy: Int = 1500;
        
        public override func set(config: Dictionary<String, Any>) {
            super.set(config: config)
            if let status = config["statusGps"] as? Bool {
                statusGps = status
            }
            
            if let frequency = config["frequencyGps"] as? Double {
                frequencyGps = frequency
            }
            
            if let minGps = config["minGpsAccuracy"] as? Double {
                minGpsAccuracy = minGps
            }
            
            if let expTime = config["expirationTime"] as? Int64 {
                expirationTime = expTime
            }
            
            if let sAll = config["saveAll"] as? Bool {
                saveAll = sAll
            }
        }
        
        public func apply(closure:(_ config: LocationsSensor.Config ) -> Void ) -> Self {
            closure(self)
            return self
        }
    }
    
    public override convenience init(){
        self.init(LocationsSensor.Config())
    }
    
    public init(_ config:LocationsSensor.Config){
        self.CONFIG = config
        super.init()
        self.locationManager.delegate = self;
        self.initializeDbEngine(config: config)
        if config.debug { print(LocationsSensor.TAG,"Location sensor is created.") }
    }
    
    public override func start() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            if CONFIG.debug { print(LocationsSensor.TAG,"Location service is not authorized. Send an authorization request.") }
            locationManager.requestAlwaysAuthorization()
            return
        case .restricted, .denied:
            // Disable location features
            // disableMyLocationBasedFeatures()
            if CONFIG.debug { print(LocationsSensor.TAG,"Location service is restricted or denied. Please check the location sensor setting from Settings.app.") }
            return
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable basic location features
            // enableMyWhenInUseFeatures()
            break
        }
        
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            if CONFIG.debug { print(LocationsSensor.TAG,"Location services are not enabled. \(#line)") }
            return
        }
        
        if CONFIG.debug { print(LocationsSensor.TAG,"Start location services") }
        self.startLocationServices()
        self.notificationCenter.post(name: .actionAwareLocationStart, object: nil)

        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: CONFIG.frequencyGps, repeats: true, block: { (timer) in
                let now = Date()
                if let lastLocation = self.LAST_DATA {
                    // check timeout (second)
                    let currentTimestamp = now.timeIntervalSince1970
                    let lastLocationTimestamp = lastLocation.timestamp.timeIntervalSince1970
                    if self.CONFIG.debug {
                        print(LocationsSensor.TAG, "Passed         : \(Int64(currentTimestamp - lastLocationTimestamp)) second")
                        print(LocationsSensor.TAG, "Expiration Time: \(self.CONFIG.expirationTime) second")
                    }
                    if Int64(currentTimestamp - lastLocationTimestamp) < self.CONFIG.expirationTime {
                        if self.CONFIG.debug { print(LocationsSensor.TAG, "Save the last location data") }
                        self.saveLocationsData(locations: [lastLocation], eventTime: now)
                    }else{
                        if let currentLocation = self.locationManager.location {
                            self.saveLocationsData(locations: [currentLocation], eventTime: now)
                            self.LAST_DATA = currentLocation
                            if self.CONFIG.debug { print(LocationsSensor.TAG, "Get a new location data due to data expiration") }
                        }
                    }
                }else{
                    if let currentLocation = self.locationManager.location {
                        self.saveLocationsData(locations: [currentLocation], eventTime: now)
                        self.LAST_DATA = currentLocation
                        if self.CONFIG.debug { print(LocationsSensor.TAG, "Get a new location data ") }
                    }else{
                        if self.CONFIG.debug { print(LocationsSensor.TAG, "Location data is lost") }
                    }
                }
            });
        }
    }
    
    
    public override func stop() {
        if CONFIG.debug { print(LocationsSensor.TAG,"Stop location services") }
        self.stopLocationServices()
        self.notificationCenter.post(name: .actionAwareLocationStop, object: nil)
        if let t = self.timer {
            t.invalidate()
            self.timer = nil
        }
    }
    
    public override func sync(force: Bool = false) {
        if CONFIG.debug { print(LocationsSensor.TAG,"Start database sync") }
        if let enging = self.dbEngine {
            enging.startSync(LocationsData.TABLE_NAME, LocationsData.self, DbSyncConfig().apply(closure: { config in
                config.debug = CONFIG.debug
            }))
        }
        self.notificationCenter.post(name: .actionAwareLocationSync,
                                     object: nil)
    }
    
    func startLocationServices(){
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.distanceFilter = CONFIG.minGpsAccuracy // In meters.
        // Configure and start the service.
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = false
        }
        
        if let uwAccuracy = CONFIG.accuracy {
            locationManager.desiredAccuracy = uwAccuracy
        }else{
            if CONFIG.minGpsAccuracy == 0 {
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            } else if CONFIG.minGpsAccuracy <= 5.0 {
                locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            } else if CONFIG.minGpsAccuracy <= 25.0 {
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            } else if CONFIG.minGpsAccuracy <= 100.0 {
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            } else if CONFIG.minGpsAccuracy <= 1000.0 {
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            } else if CONFIG.minGpsAccuracy <= 3000.0 {
                locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            } else {
                locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            }
        }
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringVisits()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingHeading()
        if let uwRegions = self.CONFIG.regions{
            for uwRegion in uwRegions {
                locationManager.startMonitoring(for: uwRegion)
            }
        }
    }
    
    func stopLocationServices(){
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopMonitoringVisits()
        if let uwRegions = self.CONFIG.regions{
            for uwRegion in uwRegions {
                locationManager.stopMonitoring(for: uwRegion)
            }
        }
    }
}

extension LocationsSensor: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            self.startLocationServices()
            break
        case .authorizedWhenInUse:
            self.startLocationServices()
            break
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if locations.count > 0 {
            if self.LAST_DATA == nil {
                self.saveLocationsData(locations: locations, eventTime: nil)
            }
            self.LAST_DATA = locations.last
        }
        
        if self.CONFIG.saveAll {
            self.saveLocationsData(locations: locations, eventTime: nil)
        }
    }
    
    func saveLocationsData(locations:[CLLocation], eventTime:Date?){
        var dataArray = Array<LocationsData>()
        for location in locations{
            let data = LocationsData()
            if let uwEventTime = eventTime {
                data.timestamp = Int64(uwEventTime.timeIntervalSince1970 * 1000)
            }else{
                data.timestamp = Int64(location.timestamp.timeIntervalSince1970 * 1000)
            }
            data.altitude  = location.altitude
            data.latitude  = location.coordinate.latitude
            data.longitude = location.coordinate.longitude
            data.course   = location.course
            data.speed     = location.speed
            data.verticalAccuracy = location.verticalAccuracy
            data.horizontalAccuracy = location.horizontalAccuracy
            if let floor = location.floor {
                data.floor = floor.level as NSNumber
            }
            dataArray.append(data)
            if let observer = CONFIG.sensorObserver {
                observer.onLocationChanged(data: data)
            }
        }
        if let enging = self.dbEngine {
            enging.save(dataArray, LocationsData.TABLE_NAME)
        }
        self.notificationCenter.post(name: .actionAwareLocations, object: nil)
    }
    
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // TODO: development
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // TODO: development
    }
    
}
