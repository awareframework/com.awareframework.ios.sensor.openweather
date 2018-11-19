//
//  OpenWeatherData.swift
//  com.awareframework.ios.sensor.openweather
//
//  Created by Yuuki Nishiyama on 2018/11/18.
//

import UIKit
import com_aware_ios_sensor_core

public class OpenWeatherData: AwareObject {
    
    public static let TABLE_NAME = "openWeatherData"
    
    @objc dynamic var city:String = ""
    @objc dynamic var temperature:Double = 0.0
    @objc dynamic var temperatureMax:Double = 0.0
    @objc dynamic var temperatureMin:Double = 0.0
    @objc dynamic var unit:String = ""
    @objc dynamic var humidity:Double = 0.0
    @objc dynamic var pressure:Double = 0.0
    
    @objc dynamic var windSpeed:Double   = 0.0
    @objc dynamic var windDegrees:Double = 0.0
    
    @objc dynamic var cloudiness:Double = 0.0
    @objc dynamic var weatherIconId:Int = 0
    @objc dynamic var weatherDescription:String = ""
    @objc dynamic var rain:Double = 0.0
    @objc dynamic var snow:Double = 0.0
    @objc dynamic var sunrise:Int64 = 0
    @objc dynamic var sunset:Int64  = 0
    
    public override func setValuesForKeys(_ keyedValues: [String : Any]) {
        
        if let city = keyedValues["name"] as? String {
            self.city = city
        }
        
        if let main = keyedValues["main"] as? Dictionary<String,Any>{
            if let temp = main["temp"] as? Double {
                self.temperature = temp
            }
            if let tempMax = main["temp_max"] as? Double {
                self.temperatureMax = tempMax
            }
            if let tempMin = main["temp_min"] as? Double {
                self.temperatureMin = tempMin
            }
            if let humidity = main["humidity"] as? Double {
                self.humidity = humidity
            }
            if let pressure = main["pressure"] as? Double {
                self.pressure = pressure
            }
        }

        if let wind = keyedValues["wind"] as? Dictionary<String,Any> {
            if let deg = wind["deg"] as? Double {
                self.windDegrees = deg
            }
            if let speed = wind["speed"] as? Double {
                self.windSpeed = speed
            }
        }
        
        if let clouds = keyedValues["clouds"] as? Dictionary<String,Any> {
            if let all = clouds["clouds"] as? Double {
                self.cloudiness = all
            }
        }
        
        if let weathers = keyedValues["weather"] as? Array<Dictionary<String,Any>>{
            for weather in weathers {
                if let weatherId = weather["id"] as? Int {
                    self.weatherIconId = weatherId
                }
                if let weatherDescription = weather["description"] as? String {
                    self.weatherDescription = weatherDescription
                }
            }
        }
        
        if let sys = keyedValues["sys"] as? Dictionary<String,Any> {
            if let sunset = sys["sunset"] as? Int64 {
                self.sunset = sunset
            }
            if let sunrise = keyedValues["sunrise"] as? Int64 {
                self.sunrise = sunrise
            }
        }
        
        // rain
        //   rain.1h Rain volume for the last 1 hour
        //   rain.3h Rain volume for the last 3 hours
        if let rain = keyedValues["rain"] as? Dictionary<String,Any>{
            if let rain1h = rain["1h"] as? Double {
                self.rain = rain1h
            }
        }
        
        // snow
        //   snow.1h Snow volume for the last 1 hour
        //   snow.3h Snow volume for the last 3 hours
        if let snow = keyedValues["snow"] as? Dictionary<String,Any>{
            if let snow1h = snow["1h"] as? Double {
                self.snow = snow1h
            }
        }
        
    }
    
    override public func toDictionary() -> Dictionary<String, Any> {
        var dict = super.toDictionary()
        dict["city"] = city
        dict["temperature"] = temperature
        dict["temperatureMax"] = temperatureMax
        dict["temperatureMin"] = temperatureMin
        dict["unit"] = unit
        dict["humidity"] = humidity
        dict["pressure"] = pressure
        dict["windSpeed"] = windSpeed
        dict["windDegrees"]   = windDegrees
        dict["cloudiness"]    = cloudiness
        dict["weatherIconId"] = weatherIconId
        dict["weatherDescription"] = weatherDescription
        dict["rain"] = rain
        dict["snow"] = snow
        dict["sunrise"] = sunrise
        dict["sunset"]  = sunset
        return dict
    }
}
