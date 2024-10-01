import XCTest
import PromiseKit
import SwiftyJSON
import Nimble
import Quick
@testable import PrimeSDK

final class ConfigurationLoadingServiceTests: XCTestCase {
    class APIServiceMock: APIServiceProtocol {
        func fetchJSON(url: String) -> Promise<JSON> {
            if url == "https://www.technolab.com.ru/files/AppConfiguration.json" {
                return Promise { seal in seal.fulfill(JSON("\"status\": \"ok\"")) }
            }
            return Promise { _ in }
        }

        func request(
            action: String,
            configRequest: ConfigRequest,
            configResponse: ConfigResponse
        ) -> Promise<DeserializedViewMap> {
            return Promise { _ in }
        }
    }

    func testLocalConfigurationLoadingService() {
    }
}
