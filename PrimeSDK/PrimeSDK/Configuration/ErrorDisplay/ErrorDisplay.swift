import Alamofire
import Foundation
import SwiftyJSON

/**
 Is responsible for detection of custom errors from backend and its display in the UI
 */
protocol ErrorDisplay {
    init(json: JSON, parsingService: ParsingService) throws
    func validate(response: DataResponse<JSON>) throws -> String?
}
