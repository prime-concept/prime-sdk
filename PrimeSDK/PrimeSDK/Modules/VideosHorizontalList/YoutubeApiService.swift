import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

class YoutubeApiService {
    lazy var sessionManager: SessionManager = {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 1000
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let manager = SessionManager(
            configuration: config
        )
        return manager
    }()

    let apiKey: String

    init(
        apiKey: String
    ) {
        self.apiKey = apiKey
    }

    func loadVideoSnippets(ids: [String]) -> Promise<[YoutubeVideoSnippet]> {
        return Promise { seal in
            let params: [String: String] = [
                "key": apiKey,
                "part": "snippet",
                "id": ids.joined(separator: ",")
            ]

            self.sessionManager.request(
                "https://www.googleapis.com/youtube/v3/videos",
                method: .get,
                parameters: params,
                encoding: URLEncoding.default,
                headers: nil
            ).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    seal.reject(error)
                case .success(let json):
                    let snippets = json["items"].arrayValue.compactMap { YoutubeVideoSnippet(json: $0) }
                    seal.fulfill(snippets)
                }
            }
        }
    }
}

class YoutubeVideoSnippet {
    var id: String
    var title: String
    var author: String
    var status: YoutubeVideoLiveState?
    var thumbnailImage: String

    init?(json: JSON) {
        guard let id = json["id"].string else {
            return nil
        }
        self.id = id
        self.title = json["snippet"]["title"].stringValue
        self.author = json["snippet"]["channelTitle"].stringValue
        self.status = YoutubeVideoLiveState(rawValue: json["snippet"]["liveBroadcastContent"].stringValue)
        self.thumbnailImage = json["snippet"]["thumbnails"]["standard"]["url"].stringValue
    }
}

enum YoutubeVideoLiveState: String {
    case none, live, upcoming
}
