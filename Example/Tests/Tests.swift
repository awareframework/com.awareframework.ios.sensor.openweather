import XCTest
import com_awareframework_ios_sensor_openweather

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testConfig(){
        let interval = 30 // min
        let apiKey   = "http://openweathermap.org/"
        let unit     = "imperial"   // metric or imperial
        let config:Dictionary<String,Any> = ["interval":interval, "apiKey":apiKey, "unit":unit]
        
        // default
        var sensor = OpenWeatherSensor()
        XCTAssertEqual(sensor.CONFIG.interval, 15)
        XCTAssertEqual(sensor.CONFIG.apiKey, nil)
        XCTAssertEqual(sensor.CONFIG.unit, "metric")
        
        // apply
        sensor = OpenWeatherSensor.init(OpenWeatherSensor.Config().apply{config in
            config.interval = interval
            config.apiKey = apiKey
            config.unit = unit
        })
        XCTAssertEqual(sensor.CONFIG.interval, interval)
        XCTAssertEqual(sensor.CONFIG.apiKey,   apiKey)
        XCTAssertEqual(sensor.CONFIG.unit,     unit)
        
        // init with dictionary
        sensor = OpenWeatherSensor.init(OpenWeatherSensor.Config(config))
        XCTAssertEqual(sensor.CONFIG.interval, interval)
        XCTAssertEqual(sensor.CONFIG.apiKey,   apiKey)
        XCTAssertEqual(sensor.CONFIG.unit,     unit)
        
        // set
        sensor = OpenWeatherSensor()
        sensor.CONFIG.set(config: config)
        XCTAssertEqual(sensor.CONFIG.interval, interval)
        XCTAssertEqual(sensor.CONFIG.apiKey,   apiKey)
        XCTAssertEqual(sensor.CONFIG.unit,     unit)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
