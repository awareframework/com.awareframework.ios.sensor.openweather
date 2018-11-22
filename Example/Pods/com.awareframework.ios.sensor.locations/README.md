# Aware Locations

[![CI Status](https://img.shields.io/travis/tetujin/com.awareframework.ios.sensor.locations.svg?style=flat)](https://travis-ci.org/tetujin/com.awareframework.ios.sensor.locations)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.locations.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.locations)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.locations.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.locations)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.locations.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.locations)


## Requirements
iOS 10 or later.

## Installation

com.aware.ios.sensor.locations is available through [CocoaPods](https://cocoapods.org). 

1. To install it, simply add the following line to your Podfile:

```ruby
pod 'com.awareframework.ios.sensor.locations'
```

2. Open your project ( *.xcworkspace ) and add `NSLocationAlwaysAndWhenInUseUsageDescription` and `NSLocationWhenInUseUsageDescription` to Info.plist.

3. Import com.aware.ios.sensor.locations library into your source code.
```swift
import com.awareframework.ios.sensor.locations
```

## Example usage
```swift
// To initialize the sensor
let locationSensor = LocationsSensor.init(LocationsSensor.Config().apply{config in
    config.sensorObserver = Observer()
    config.debug = true
    config.dbType = DatabaseType.REALM
    // more configuration...
})
// To start the sensor
locationSensor?.start()

// To stop the sensor
locationSensor?.stop()
```

```swift
class Observer:LocationsObserver {
    func onLocationChanged(data: LocationsData) {
    // your code here
}
}
```

## Author

Yuuki Nishiyama, tetujin@ht.sfc.keio.ac.jp

## License
Copyright (c) 2018 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
