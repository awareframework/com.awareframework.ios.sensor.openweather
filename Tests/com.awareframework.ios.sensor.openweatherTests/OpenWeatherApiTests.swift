import XCTest
@testable import com_awareframework_ios_sensor_openweather

/// Answers every request with a fixed JSON body after a short delay, without the network.
final class StubWeatherProtocol: URLProtocol {
    static let body = Data(#"{"name":"Stub","main":{"temp":12.5}}"#.utf8)
    static var delay: TimeInterval = 0.05
    private var cancelled = false

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.delay) { [weak self] in
            guard let self, !self.cancelled, let url = self.request.url else { return }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: Self.body)
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() { cancelled = true }
}

final class OpenWeatherApiTests: XCTestCase {

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubWeatherProtocol.self]
        return URLSession(configuration: config)
    }

    private func makeApi(_ session: URLSession) -> OpenWeatherApi {
        let config = OpenWeatherSensor.Config()
        config.apiKey = "test"
        return OpenWeatherApi(longitude: 139.7, latitude: 35.6, config: config, session: session)
    }

    /// The crash: every API object made a background session with the same identifier, and a task
    /// created in the invalidated previous one threw (SIGABRT). Many objects in a row must all work.
    func testRequestsFromManyApiObjectsInARowAllComplete() {
        let session = makeSession()
        var apis: [OpenWeatherApi] = []
        let done = expectation(description: "every request delivers its body")
        done.expectedFulfillmentCount = 5
        for _ in 0..<5 {
            let api = makeApi(session)
            apis.append(api)
            api.getWeatherData { data in
                XCTAssertTrue(Thread.isMainThread)
                XCTAssertEqual(data, StubWeatherProtocol.body)
                done.fulfill()
            }
        }
        wait(for: [done], timeout: 5)
        XCTAssertEqual(apis.count, 5)
    }

    func testCancelledRequestDoesNotCallCompletion() {
        let api = makeApi(makeSession())
        let notCalled = expectation(description: "completion of a cancelled request")
        notCalled.isInverted = true
        api.getWeatherData { _ in notCalled.fulfill() }
        api.cancel()
        wait(for: [notCalled], timeout: 0.5)
    }

    func testNewRequestReplacesThePreviousOne() {
        let api = makeApi(makeSession())
        let first = expectation(description: "first request (replaced)")
        first.isInverted = true
        let second = expectation(description: "second request")
        api.getWeatherData { _ in first.fulfill() }
        api.getWeatherData { _ in second.fulfill() }
        wait(for: [first, second], timeout: 2)
    }
}
