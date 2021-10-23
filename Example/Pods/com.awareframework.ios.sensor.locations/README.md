# AWARE: Locations

[![CI Status](https://img.shields.io/travis/awareframework/com.awareframework.ios.sensor.locations.svg?style=flat)](https://travis-ci.org/awareframework/com.awareframework.ios.sensor.locations)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.locations.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.locations)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.locations.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.locations)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.locations.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.locations)

The locations sensor provides the best location estimate for the users’ current location, automatically. The location data is provided by [Core Location](https://developer.apple.com/documentation/corelocation).

## Requirements
iOS 10 or later.

## Installation

com.aware.ios.sensor.locations is available through [CocoaPods](https://cocoapods.org). 

1. To install it, simply add the following line to your Podfile:

```ruby
pod 'com.awareframework.ios.sensor.locations'
```

2. Import com.aware.ios.sensor.locations library into your source code.
```swift
import com_awareframework_ios_sensor_locations
```

3. Open your project ( *.xcworkspace ) and add `NSLocationAlwaysAndWhenInUseUsageDescription` and `NSLocationWhenInUseUsageDescription` into Info.plist.

## Public functions

### LocationsSensor

+ `init(config:LocationsSensor.Config?)` : Initializes the locations sensor with the optional configuration.
+ `start()`: Starts the locations sensor with the optional configuration.
+ `stop()`: Stops the service.

### LocationsSensor.Config

Class to hold the configuration of the sensor.

#### Fields
+ `sensorObserver: LocationsObserver?` Callback for live data updates. (default = `null`)
+ `frequency: Int` how frequent to check the location, in seconds. By default, every 180 seconds. Setting to 0 (zero) will keep the GPS location tracking always on. (default = 180)
+ `accuracy: Int`  the minimum acceptable accuracy of GPS location, in meters. By default, 150 meters. Setting to 0 (zero) will keep the GPS location tracking always on. (default = 150)
+ `expirationTime: Int64` the amount of elapsed time, in seconds, until the location is considered outdated. By default, 300 seconds. (default = 300)
+ `saveAll: Boolean` Whether to save all the location updates or not. (default = `false`)
+ `enabled: Boolean` Sensor is enabled or not. (default = `false`)
+ `debug: Boolean` enable/disable logging to `Logcat`. (default = `false`)
+ `label: String` Label for the data. (default = "")
+ `deviceId: String` Id of the device that will be associated with the events and the sensor. (default = "")
+ `dbEncryptionKey` Encryption key for the database. (default = `null`)
+ `dbType: Engine` Which db engine to use for saving data. (default = `Engine.DatabaseType.NONE`)
+ `dbPath: String` Path of the database. (default = "aware_locations")
+ `dbHost: String` Host for syncing the database. (default = `null`)

## Broadcasts

### Fired Broadcasts

+ `LocationsSensor.ACTION_AWARE_LOCATIONS` fired when new location available.
+ `LocationsSensor.ACTION_AWARE_GPS_LOCATION_ENABLED` fired when GPS location is active.
+ `LocationsSensor.ACTION_AWARE_GPS_LOCATION_DISABLED` fired when GPS location disabled.

### Received Broadcasts

+ `LocationsSensor.ACTION_AWARE_LOCATIONS_START`: received broadcast to start the sensor.
+ `LocationsSensor.ACTION_AWARE_LOCATIONS_STOP`: received broadcast to stop the sensor.
+ `LocationsSensor.ACTION_AWARE_LOCATIONS_SYNC`: received broadcast to send sync attempt to the host.
+ `LocationsSensor.ACTION_AWARE_LOCATIONS_SET_LABEL`: received broadcast to set the data label. Label is expected in the `LocationsSensor.EXTRA_LABEL` field of the intent extras.

## Data Representations

### Locations Data

Contains the locations profiles.

| Field     | Type   | Description                                                     |
| --------- | ------ | --------------------------------------------------------------- |
| latitude  | Double | The latitude in degrees.                            |
| longitude | Double | The longitude in degrees.                          |
| course   | Double  | The direction in which the device is traveling, measured in degrees and relative to due north.                            |
| speed     | Float  | The instantaneous speed of the device, measured in meters per second.           |
| altitude  | Double | The altitude, measured in meters.            |
| floor     | Double? | The logical floor of the building in which the user is located. | 
| horizontalAccuracy  | Double  | The radius of uncertainty for the location, measured in meters.  |
| verticalAccuracy    | Double  | The accuracy of the altitude value, measured in meters.     |
| deviceId  | String | AWARE device UUID                                               |
| label     | String | Customizable label. Useful for data calibration or traceability |
| timestamp | Long   | Unixtime milliseconds since 1970                                |
| timezone  | Int    | Rimezone of the device                          |
| os        | String | Operating system of the device (e.g., ios)                    |

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

Yuuki Nishiyama, yuukin@iis.u-tokyo.ac.jp

## Related links
- [ Apple | Core Location](https://developer.apple.com/documentation/corelocation)
- [ Apple | CLLocation](https://developer.apple.com/documentation/corelocation/cllocation)

## License
Copyright (c) 2021 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
