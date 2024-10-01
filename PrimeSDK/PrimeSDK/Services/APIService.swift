import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

extension ConfigRequest.RequestMethod {
    var alamofireMethod: HTTPMethod {
        switch self {
        case .get:
            return HTTPMethod.get
        case .delete:
            return HTTPMethod.delete
        case .post:
            return HTTPMethod.post
        case .put:
            return HTTPMethod.put
        }
    }
}

extension ConfigRequest.ContentType {
    var alamofireType: ParameterEncoding {
        switch self {
        case .json:
            return JSONEncoding.default
        case .url:
            return URLEncoding.default
        }
    }
}

enum APIError: Error {
    case invalidURL
}

public protocol APIServiceProtocol {
    func request(
        action: String,
        configRequest: ConfigRequest,
        configResponse: ConfigResponse,
        sdkDelegate: PrimeSDKApiDelegate?
    ) -> (promise: Promise<DeserializedViewMap>, cancel: () -> Void)
    func fetchJSON(url: String, headers: [String: String]) -> Promise<JSON>
}

public class APIService: APIServiceProtocol {
    lazy var sessionManager: SessionManager = {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 1000
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let manager = SessionManager(
            configuration: config
        )
        return manager
    }()

    private var sdkManager: PrimeSDKManagerProtocol?

    public init(sdkManager: PrimeSDKManagerProtocol) {
        self.sdkManager = sdkManager
    }

    public init() {}

    public typealias CancelationToken = () -> Void

    public func request(
        action: String,
        configRequest: ConfigRequest,
        configResponse: ConfigResponse,
        sdkDelegate: PrimeSDKApiDelegate?
    ) -> (promise: Promise<DeserializedViewMap>, cancel: CancelationToken) {
        var isCanceled = false
        var dataRequest: DataRequest?
        var manager = self.sdkManager

        let logError: (String, Int?, String, Double?) -> Void = { [weak self] request, code, error, time in
            let timeString = time.flatMap { String(format: "%.4f", $0) }
            self?.sdkManager?.analyticsDelegate?.sdkNetworkErrorOccurred(
                request: request,
                code: code,
                error: error,
                time: timeString
            )
        }

        let promise = Promise<DeserializedViewMap> { seal in
            guard let method = configRequest.method else {
                seal.reject(NSError())
                return
            }

            sdkDelegate?.wrapRequest().done { [weak self] in
                guard let self = self else {
                    seal.reject(NSError())
                    return
                }
                dataRequest = self.sessionManager.request(
                    configRequest.url,
                    method: method.alamofireMethod,
                    parameters: configRequest.parameters,
                    encoding: configRequest.contentType?.alamofireType ?? URLEncoding.default,
                    headers: configRequest.headers
                )
                dataRequest?.validate().responseSwiftyJSON { response in
                    sdkDelegate?.log(sdkResponse: response)

                    guard !isCanceled else {
                        seal.reject(PMKError.cancelled)
                        return
                    }

                    sdkDelegate?.requestLoaded(configRequest: configRequest, response: response)
                    switch response.result {
                    case .failure(let error):
                        logError(
                            configRequest.url,
                            response.response?.statusCode ?? 0,
                            error.localizedDescription,
                            response.timeline.requestDuration
                        )
                        seal.reject(error)
                    case .success(let json):
                        if
                            let errorDisplay = configResponse.errorDisplay,
                            let errorText = try? errorDisplay.validate(response: response) {
                            logError(
                                configRequest.url,
                                response.response?.statusCode ?? 0,
                                errorText,
                                response.timeline.requestDuration
                            )
                            seal.reject(BackendGeneratedError(text: errorText))
                            return
                        }
                        configResponse.deserializer?.deserialize(json: json).done {
                            deserializedViewMap in
                            seal.fulfill(deserializedViewMap)
                        }.catch { error in
                            logError(
                                configRequest.url,
                                response.response?.statusCode ?? 0,
                                error.localizedDescription,
                                response.timeline.requestDuration
                            )
                            seal.reject(error)
                        }
                    }
                }

                if let request = dataRequest?.request {
                    sdkDelegate?.log(sdkRequest: request)
                }
            }.catch { error in
                logError(configRequest.url, nil, error.localizedDescription, nil)
                seal.reject(error)
            }
        }
        let cancel = {
            isCanceled = true
            dataRequest?.cancel()
        }
        return (promise: promise, cancel: cancel)
    }

    public func fetchJSON(url: String, headers: [String: String] = [:]) -> Promise<JSON> {
        return Promise { seal in
            guard let url = URL(string: url) else {
                seal.reject(APIError.invalidURL)
                return
            }
            var request = try URLRequest(url: url, method: .get, headers: headers)
            request.cachePolicy = .reloadIgnoringCacheData

            Alamofire.request(request).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    seal.reject(error)
                case .success(let json):
                    seal.fulfill(json)
                }
            }
        }
    }
}
