import XCTest
import RealmSwift
import com_awareframework_ios_sensor_openweather
import com_awareframework_ios_sensor_core

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
         Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testObserver(){
        
        #if targetEnvironment(simulator)
        print("This test requires a real device.")
        
        #else
        
        class Observer:OpenWeatherObserver{
            weak var openWeatherExpectation: XCTestExpectation?
            func onDataChanged(data: OpenWeatherData) {
                print(#function)
                self.openWeatherExpectation?.fulfill()
            }
        }
        
        let openWeatherObserverExpect = expectation(description: "OpenWeather observer")
        let observer = Observer()
        observer.openWeatherExpectation = openWeatherObserverExpect
        let sensor = OpenWeatherSensor.init(OpenWeatherSensor.Config().apply{ config in
            config.sensorObserver = observer
            config.apiKey = "YOUR_API_KEY"
            config.dbType = .REALM
        })

        if let engine = sensor.dbEngine {
            engine.removeAll(OpenWeatherData.self)
        }
        
        let openWeatherStorageExpect = expectation(description: "OpenWeather storage")
        
        let obs = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareOpenWeather,
                                                         object: nil,
                                                         queue: .main) { (notification) in
            if let engine = sensor.dbEngine {
                if let results = engine.fetch(OpenWeatherData.self, nil) as? Results<Object>{
                    print(results)
                    openWeatherStorageExpect.fulfill()
                    XCTAssertEqual(results.count, 1)
                }else{
                    XCTFail()
                }
            }
        }
        
        sensor.start()

        wait(for: [openWeatherObserverExpect,openWeatherStorageExpect], timeout: 10)
        sensor.stop()
        NotificationCenter.default.removeObserver(obs)
        
        #endif
    }
    
    func testControllers() {
        let sensor = OpenWeatherSensor()

        /// test set label action ///
        let expectSetLabel = expectation(description: "set label")
        let newLabel = "hello"
        let labelObserver = NotificationCenter.default.addObserver(forName: .actionAwareOpenWeatherSetLabel, object: nil, queue: .main) { (notification) in
            let dict = notification.userInfo;
            if let d = dict as? Dictionary<String,String>{
                XCTAssertEqual(d[OpenWeatherSensor.EXTRA_LABEL], newLabel)
            }else{
                XCTFail()
            }
            expectSetLabel.fulfill()
        }
        sensor.set(label:newLabel)
        wait(for: [expectSetLabel], timeout: 5)
        NotificationCenter.default.removeObserver(labelObserver)

        /// test sync action ////
        let expectSync = expectation(description: "sync")
        let syncObserver = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareOpenWeatherSync , object: nil, queue: .main) { (notification) in
            expectSync.fulfill()
            print("sync")
        }
        sensor.sync()
        wait(for: [expectSync], timeout: 5)
        NotificationCenter.default.removeObserver(syncObserver)


        #if targetEnvironment(simulator)
        print("This test requires a real device.")
        
        #else
        
        //// test start action ////
        let expectStart = expectation(description: "start")
        let observer = NotificationCenter.default.addObserver(forName: .actionAwareOpenWeatherStart,
                                                              object: nil,
                                                              queue: .main) { (notification) in
                                                                expectStart.fulfill()
                                                                print("start")
        }
        sensor.start()
        wait(for: [expectStart], timeout: 5)
        NotificationCenter.default.removeObserver(observer)


        /// test stop action ////
        let expectStop = expectation(description: "stop")
        let stopObserver = NotificationCenter.default.addObserver(forName: .actionAwareOpenWeatherStop, object: nil, queue: .main) { (notification) in
            expectStop.fulfill()
            print("stop")
        }
        sensor.stop()
        wait(for: [expectStop], timeout: 5)
        NotificationCenter.default.removeObserver(stopObserver)
        
        #endif
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
        
        sensor.CONFIG.interval = -4
        XCTAssertEqual(sensor.CONFIG.interval, 30)
        
        sensor.CONFIG.unit = "hoge"
        XCTAssertEqual(sensor.CONFIG.unit, "imperial")
    }
    
    func testOpenWeatherData(){
        let dict = OpenWeatherData().toDictionary()
        XCTAssertEqual(dict["city"] as? String, "")
        XCTAssertEqual(dict["temperature"] as? Double, 0)
        XCTAssertEqual(dict["temperatureMax"] as? Double, 0)
        XCTAssertEqual(dict["temperatureMin"] as? Double, 0)
        XCTAssertEqual(dict["unit"] as? String, "")
        XCTAssertEqual(dict["humidity"]  as? Double, 0)
        XCTAssertEqual(dict["pressure"]  as? Double, 0)
        XCTAssertEqual(dict["windSpeed"]  as? Double, 0)
        XCTAssertEqual(dict["windDegrees"]   as? Double, 0)
        XCTAssertEqual(dict["cloudiness"]  as? Double, 0)
        XCTAssertEqual(dict["weatherIconId"]  as? Int, 0)
        XCTAssertEqual(dict["weatherDescription"]  as? String, "")
        XCTAssertEqual(dict["rain"] as? Double, 0)
        XCTAssertEqual(dict["snow"]  as? Double, 0)
        XCTAssertEqual(dict["sunrise"]  as? Int64, 0)
        XCTAssertEqual(dict["sunset"]  as? Int64, 0)
    }
    
    func testSyncModule(){
        #if targetEnvironment(simulator)
        
        print("This test requires a real OpenWeather.")
        
        #else
        // success //
        let sensor = OpenWeatherSensor.init(OpenWeatherSensor.Config().apply{ config in
            config.debug = true
            config.dbType = .REALM
            config.dbHost = "node.awareframework.com:1001"
            config.dbPath = "sync_db"
        })
        if let engine = sensor.dbEngine as? RealmEngine {
            engine.removeAll(OpenWeatherData.self)
            for _ in 0..<100 {
                engine.save(OpenWeatherData())
            }
        }
        let successExpectation = XCTestExpectation(description: "success sync")
        let observer = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareOpenWeatherSyncCompletion,
                                                              object: sensor, queue: .main) { (notification) in
                                                                if let userInfo = notification.userInfo{
                                                                    if let status = userInfo["status"] as? Bool {
                                                                        if status == true {
                                                                            successExpectation.fulfill()
                                                                        }
                                                                    }
                                                                }
        }
        sensor.sync(force: true)
        wait(for: [successExpectation], timeout: 20)
        NotificationCenter.default.removeObserver(observer)
        
        ////////////////////////////////////
        
        // failure //
        let sensor2 = OpenWeatherSensor.init(OpenWeatherSensor.Config().apply{ config in
            config.debug = true
            config.dbType = .REALM
            config.dbHost = "node.awareframework.com.com" // wrong url
            config.dbPath = "sync_db"
        })
        let failureExpectation = XCTestExpectation(description: "failure sync")
        let failureObserver = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareOpenWeatherSyncCompletion,
                                                                     object: sensor2, queue: .main) { (notification) in
                                                                        if let userInfo = notification.userInfo{
                                                                            if let status = userInfo["status"] as? Bool {
                                                                                if status == false {
                                                                                    failureExpectation.fulfill()
                                                                                }
                                                                            }
                                                                        }
        }
        if let engine = sensor2.dbEngine as? RealmEngine {
            engine.removeAll(OpenWeatherData.self)
            for _ in 0..<100 {
                engine.save(OpenWeatherData())
            }
        }
        sensor2.sync(force: true)
        wait(for: [failureExpectation], timeout: 20)
        NotificationCenter.default.removeObserver(failureObserver)
        
        #endif
    }

}
