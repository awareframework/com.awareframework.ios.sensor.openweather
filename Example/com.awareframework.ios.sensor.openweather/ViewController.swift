//
//  ViewController.swift
//  com.awareframework.ios.sensor.openweather
//
//  Created by tetujin on 11/18/2018.
//  Copyright (c) 2018 tetujin. All rights reserved.
//

import UIKit
import com_awareframework_ios_sensor_openweather

class ViewController: UIViewController{

    var openWeather:OpenWeatherSensor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        openWeather = OpenWeatherSensor.init(OpenWeatherSensor.Config().apply{config in
            config.debug    = true
            config.interval = 1
            config.apiKey   = "54e5dee2e6a2479e0cc963cf20f233cc"
            config.sensorObserver = Observer()
            config.dbType   = .REALM
        })
        openWeather?.start()
    }
    
    class Observer:OpenWeatherObserver{
        func onDataChanged(data: OpenWeatherData) {
            print(data)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

