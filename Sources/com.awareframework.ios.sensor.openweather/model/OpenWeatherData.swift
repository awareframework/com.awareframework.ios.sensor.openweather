import Foundation
import com_awareframework_ios_core
import GRDB

public struct OpenWeatherData: BaseDbModelSQLite {
    public var id: Int64?
    public var timestamp: Int64 = 0
    public var deviceId: String = AwareUtils.getCommonDeviceId()
    public var label: String = ""
    public var timezone: Int = AwareUtils.getTimeZone()
    public var os: String = "iOS"
    public var jsonVersion: Int = 1
    public static let databaseTableName = "ios_open_weather"
    public static let TABLE_NAME = databaseTableName

    public var city: String = ""
    public var temperature: Double = 0
    public var temperatureMax: Double = 0
    public var temperatureMin: Double = 0
    public var unit: String = ""
    public var humidity: Double = 0
    public var pressure: Double = 0
    public var windSpeed: Double = 0
    public var windDegrees: Double = 0
    public var cloudiness: Double = 0
    public var weatherIconId: Int = 0
    public var weatherDescription: String = ""
    public var rain: Double = 0
    public var snow: Double = 0
    public var sunrise: Int64 = 0
    public var sunset: Int64 = 0

    public init() {}
    public init(_ dict: Dictionary<String, Any>) {
        timestamp          = dict["timestamp"] as? Int64 ?? 0
        label              = dict["label"] as? String ?? ""
        deviceId           = dict["deviceId"] as? String ?? AwareUtils.getCommonDeviceId()
        city               = dict["city"] as? String ?? ""
        temperature        = dict["temperature"] as? Double ?? 0
        temperatureMax     = dict["temperatureMax"] as? Double ?? 0
        temperatureMin     = dict["temperatureMin"] as? Double ?? 0
        unit               = dict["unit"] as? String ?? ""
        humidity           = dict["humidity"] as? Double ?? 0
        pressure           = dict["pressure"] as? Double ?? 0
        windSpeed          = dict["windSpeed"] as? Double ?? 0
        windDegrees        = dict["windDegrees"] as? Double ?? 0
        cloudiness         = dict["cloudiness"] as? Double ?? 0
        weatherIconId      = dict["weatherIconId"] as? Int ?? 0
        weatherDescription = dict["weatherDescription"] as? String ?? ""
        rain               = dict["rain"] as? Double ?? 0
        snow               = dict["snow"] as? Double ?? 0
        sunrise            = dict["sunrise"] as? Int64 ?? 0
        sunset             = dict["sunset"] as? Int64 ?? 0
    }

    public mutating func setValuesForKeys(_ keyedValues: [String: Any]) {
        if let city = keyedValues["name"] as? String {
            self.city = city
        }
        if let main = keyedValues["main"] as? Dictionary<String, Any> {
            if let temp = main["temp"] as? Double { self.temperature = temp }
            if let tempMax = main["temp_max"] as? Double { self.temperatureMax = tempMax }
            if let tempMin = main["temp_min"] as? Double { self.temperatureMin = tempMin }
            if let humidity = main["humidity"] as? Double { self.humidity = humidity }
            if let pressure = main["pressure"] as? Double { self.pressure = pressure }
        }
        if let wind = keyedValues["wind"] as? Dictionary<String, Any> {
            if let deg = wind["deg"] as? Double { self.windDegrees = deg }
            if let speed = wind["speed"] as? Double { self.windSpeed = speed }
        }
        if let clouds = keyedValues["clouds"] as? Dictionary<String, Any>,
           let all = clouds["all"] as? Double {
            self.cloudiness = all
        }
        if let weathers = keyedValues["weather"] as? Array<Dictionary<String, Any>> {
            for weather in weathers {
                if let weatherId = weather["id"] as? Int { self.weatherIconId = weatherId }
                if let weatherDescription = weather["description"] as? String {
                    self.weatherDescription = weatherDescription
                }
            }
        }
        if let sys = keyedValues["sys"] as? Dictionary<String, Any> {
            if let sunset = sys["sunset"] as? Int64 { self.sunset = sunset }
            if let sunrise = sys["sunrise"] as? Int64 { self.sunrise = sunrise }
        }
        if let rain = keyedValues["rain"] as? Dictionary<String, Any>,
           let rain1h = rain["1h"] as? Double {
            self.rain = rain1h
        }
        if let snow = keyedValues["snow"] as? Dictionary<String, Any>,
           let snow1h = snow["1h"] as? Double {
            self.snow = snow1h
        }
    }

    public static func createTable(queue: DatabaseQueue) throws {
        try queue.write { db in try db.create(table: databaseTableName, ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("deviceId",.text).notNull(); t.column("timestamp",.integer).notNull()
            t.column("label",.text).notNull(); t.column("city",.text).notNull()
            t.column("temperature",.double).notNull(); t.column("temperatureMax",.double).notNull()
            t.column("temperatureMin",.double).notNull(); t.column("unit",.text).notNull()
            t.column("humidity",.double).notNull(); t.column("pressure",.double).notNull()
            t.column("windSpeed",.double).notNull(); t.column("windDegrees",.double).notNull()
            t.column("cloudiness",.double).notNull(); t.column("weatherIconId",.integer).notNull()
            t.column("weatherDescription",.text).notNull(); t.column("rain",.double).notNull()
            t.column("snow",.double).notNull(); t.column("sunrise",.integer).notNull()
            t.column("sunset",.integer).notNull()
            t.column("os",.text).notNull(); t.column("timezone",.integer).notNull()
            t.column("jsonVersion",.integer).notNull()
        }}
    }
    public func toDictionary() -> Dictionary<String, Any> {
        ["id": id ?? -1, "timestamp": timestamp, "deviceId": deviceId, "label": label,
         "city": city, "temperature": temperature, "temperatureMax": temperatureMax,
         "temperatureMin": temperatureMin, "unit": unit, "humidity": humidity,
         "pressure": pressure, "windSpeed": windSpeed, "windDegrees": windDegrees,
         "cloudiness": cloudiness, "weatherIconId": weatherIconId,
         "weatherDescription": weatherDescription, "rain": rain, "snow": snow,
         "sunrise": sunrise, "sunset": sunset, "os": os, "timezone": timezone,
         "jsonVersion": jsonVersion]
    }
}
