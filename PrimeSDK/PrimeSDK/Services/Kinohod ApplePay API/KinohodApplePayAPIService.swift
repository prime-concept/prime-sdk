import Alamofire
import Foundation
import PassKit
import PromiseKit
import SwiftyJSON

public class KinohodApplePayAPIService {
    public init() {}

    private func getPath(url: URL, orderID: String) -> String {
        let slash = url.absoluteString.last == "/" ? "" : "/"
        return "\(url.absoluteString)\(slash)\(orderID)"
    }

    func putApplePayToken(
        token: KinohodApplePayToken,
        url: URL,
        orderID: String,
        apiKey: String,
        sessionID: String
    ) -> (promise: Promise<KinohodApplePayResponse>, cancel: APIService.CancelationToken) {
        var isCanceled = false
        var dataRequest: DataRequest?

        let path = getPath(url: url, orderID: orderID)

        let promise = Promise<KinohodApplePayResponse> { seal in
            dataRequest = Alamofire.request(
                path,
                method: .put,
                parameters: token.dictionary,
                encoding: JSONEncoding.default,
                headers: [
                    "apikey": apiKey,
                    "Cookie": "kinohod_session=\(sessionID)"
                ]
            ).validate().responseSwiftyJSON { response in
                print("APPLE PAY REQUEST: \(response.request?.url?.absoluteString ?? "")")

                guard !isCanceled else {
                    seal.reject(PMKError.cancelled)
                    return
                }

                switch response.result {
                case .failure(let error):
                    seal.reject(error)
                case .success(let json):
                    let response = KinohodApplePayResponse(json: json)
                    seal.fulfill(response)
                }
            }
        }
        let cancel = {
            isCanceled = true
            dataRequest?.cancel()
        }

        return (promise: promise, cancel: cancel)
    }

    func getApplePayData(
        url: URL,
        orderID: String,
        apiKey: String,
        sessionID: String
    ) -> (promise: Promise<KinohodApplePayItem>, cancel: APIService.CancelationToken) {
        var isCanceled = false
        var dataRequest: DataRequest?

        let path = getPath(url: url, orderID: orderID)

        let promise = Promise<KinohodApplePayItem> { seal in
            dataRequest = Alamofire.request(
                path,
                method: .get,
                parameters: [:],
                encoding: URLEncoding.default,
                headers: [
                    "apikey": apiKey,
                    "Cookie": "kinohod_session=\(sessionID)"
                ]
            ).validate().responseSwiftyJSON { response in
                print("APPLE PAY REQUEST: \(response.request?.url?.absoluteString ?? "")")

                guard !isCanceled else {
                    seal.reject(PMKError.cancelled)
                    return
                }

                switch response.result {
                case .failure(let error):
                    seal.reject(error)
                case .success(let json):
                    if let item = KinohodApplePayItem(json: json) {
                        seal.fulfill(item)
                    } else {
                        seal.reject(KinohodApplePayItem.ItemError.parsingError)
                    }
                }
            }
        }
        let cancel = {
            isCanceled = true
            dataRequest?.cancel()
        }
        return (promise: promise, cancel: cancel)
    }

    public func loadPKPassData(url: URL) -> (promise: Promise<Data>, cancel: APIService.CancelationToken) {
        var isCanceled = false
        var dataRequest: DataRequest?

        let promise = Promise<Data> { seal in
            dataRequest = Alamofire.request(url).validate().responseData(
                completionHandler: { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(error)
                    case .success(let data):
                        seal.fulfill(data)
                    }
                }
            )
        }
        let cancel = {
            isCanceled = true
            dataRequest?.cancel()
        }
        return (promise: promise, cancel: cancel)
    }
}
