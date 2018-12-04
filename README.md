# AWARE: Open Weather

[![CI Status](https://img.shields.io/travis/awareframework/com.awareframework.ios.sensor.openweather.svg?style=flat)](https://travis-ci.org/awareframework/com.awareframework.ios.sensor.openweather)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.openweather.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.openweather)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.openweather.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.openweather)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.openweather.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.openweather)

The Open Weather plugin allows us to collect weather information based on your location. The weather data comes from Open Weather API. For using the API, you need to prepare your API KEY on [https://openweathermap.org/api](https://openweathermap.org/api).

## Requirements
iOS 10 or later

## Installation
com.awareframework.ios.sensor.openweather is available through [CocoaPods](https://cocoapods.org). 

1. To install it, simply add the following line to your Podfile:
```ruby
pod 'com.awareframework.ios.sensor.openweather'
```

2. com_aware_ios_sensor_openweather  library into your source code.
```swift
import com_awareframework_ios_sensor_openweather
```

## Public functions

### OpenWeatherSensor

+ `init(config:OpenWeatherSensor.Config?)` : Initializes the open weather sensor with the optional configuration.
+ `start()`: Starts the open weather sensor with the optional configuration.
+ `stop()`: Stops the service.

### OpenWeatherSensor.Config

Class to hold the configuration of the sensor.

#### Fields
+ `sensorObserver: OpenWeatherObserver`: Callback for live data updates.
* `interval: Int`: How frequently to fetch weather information (in minutes), (default = 60)
* `units: String`: imperial or metric (default = "metric")
* `apiKey: String`: OpenWeather API key. Get your free API key from [openweathermap.org](https://openweathermap.org/api) (default = `null`)
+ `enabled: Boolean` Sensor is enabled or not. (default = `false`)
+ `debug: Boolean` enable/disable logging to Xcode console. (default = `false`)
+ `label: String` Label for the data. (default = "")
+ `deviceId: String` Id of the device that will be associated with the events and the sensor. (default = "")
+ `dbEncryptionKey` Encryption key for the database. (default = `null`)
+ `dbType: Engine` Which db engine to use for saving data. (default = `Engine.DatabaseType.NONE`)
+ `dbPath: String` Path of the database. (default = "aware_openweather")
+ `dbHost: String` Host for syncing the database. (default = `null`)

## Broadcasts

### Fired Broadcasts

+ `OpenWeatherSensor.ACTION_AWARE_OPENWEATHER` fired when gyroscope saved data to db after the period ends.

### Received Broadcasts

+ `OpenWeatherSensor.ACTION_AWARE_OPENWEATHER_START`: received broadcast to start the sensor.
+ `OpenWeatherSensor.ACTION_AWARE_OPENWEATHER_STOP`: received broadcast to stop the sensor.
+ `OpenWeatherSensor.ACTION_AWARE_OPENWEATHER_SYNC`: received broadcast to send sync attempt to the host.
+ `OpenWeatherSensor.ACTION_AWARE_OPENWEATHER_SET_LABEL`: received broadcast to set the data label. Label is expected in the `OpenWeatherSensor.EXTRA_LABEL` field of the intent extras.

## Data Representations

### OpenWeather Data

Contains the raw sensor data.

|Field | Type | Description|
|----- | ---- | -----------|
|city           | String | weather's city                       |
|temperature	| Double | current atmospheric temperature      |
|temperatureMax | Double | forecast highest temperature         |
|temperatureMin | Double | forecast lowest temperature          |
|unit           | String | measurement unit (metric, imperial)  |
|humidity       | Double | forecast humidity percentage         |
|pressure       | Double | atmospheric pressure                 |
|windSpeed      | Double | wind's speed in m/s                  |
|windDegrees    | Double | wind's direction                     |
|cloudiness     | Double | percent amount of clouds in the sky  |
|rain           | Double | amount of rain in past hour, in millimeters |
|snow           | Double | amount of snow in past hour, in millimeters |
|sunrise        | Double | timestamp of sunrise                 |
|sunset         | Double | timestamp of sunset                  |
|weatherIconId  | Int    | icon ID from OpenWeather             |
|weatherDescription | String | forecast description             |
| label     | String | Customizable label. Useful for data calibration or traceability |
| deviceId  | String | AWARE device UUID                                               |
| label     | String | Customizable label. Useful for data calibration or traceability |
| timestamp | Int64   | unixtime milliseconds since 1970         |
| timezone  | Int    | Raw timezone offset of the device         |
| os        | String | Operating system of the device (e.g., ios)|


## Example usage
```swift
openWeather = OpenWeatherSensor.init(OpenWeatherSensor.Config().apply{config in
    config.interval = 15 // 15min
    config.apiKey   = "YOUR_API_KEY"
    config.sensorObserver = Observer()
})
openWeather?.start()
```

```swift
class Observer:OpenWeatherObserver{
    func onDataChanged(data: OpenWeatherData) {
        // Your code here
    }
}
```

## Author

Yuuki Nishiyama, tetujin@ht.sfc.keio.ac.jp

## License

Copyright (c) 2018 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
