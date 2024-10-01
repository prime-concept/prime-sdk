import Foundation
import SwiftyJSON

struct DataExpressionProcessor: Equatable {
    private let tokens: [String]

    init(tokens: [String]) {
        self.tokens = tokens
    }

    func process(json: JSON) -> JSON {
//        let start = CFAbsoluteTimeGetCurrent()
        let res = getDictionaryData(json: json)
//        let diff = CFAbsoluteTimeGetCurrent() - start
//        print("\(diff)")
        return res
    }

    private func getDictionaryData(json: JSON) -> JSON {
        if let dict = json.dictionaryObject {
            var current: Any? = dict
            for component in tokens {
                if
                    let index = Int(component),
                    let array = current as? [Any]
                {
                    if index < array.count {
                        current = array[index]
                    } else {
                        current = nil
                        break
                    }
                } else if let dictionary = current as? [String: Any] {
                    current = dictionary[String(component)]
                }
            }
            let res = JSON(rawValue: current) ?? JSON.null
            return res
        } else if json.array != nil {
            let jsonKeys: [JSONSubscriptType] = self.tokens.map {
                if let intValue = Int($0) {
                    return intValue
                } else {
                    return $0
                }
            }
            return json[jsonKeys]
        }
        return json
    }
}
