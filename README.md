# com.awareframework.ios.sensor.openweather

[![CI Status](https://img.shields.io/travis/awareframework/com.awareframework.ios.sensor.openweather.svg?style=flat)](https://travis-ci.org/awareframework/com.awareframework.ios.sensor.openweather)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.openweather.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.openweather)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.openweather.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.openweather)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.openweather.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.openweather)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 10 or later

## Installation

com.awareframework.ios.sensor.openweather is available through [CocoaPods](https://cocoapods.org). 

1. To install it, simply add the following line to your Podfile:
```ruby
pod 'com.awareframework.ios.sensor.openweather'
```

2. com_aware_ios_sensor_activityrecognition  library into your source code.
```swift
import com_awareframework_ios_sensor_openweather
```

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
