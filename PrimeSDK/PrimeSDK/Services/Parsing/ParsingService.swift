import Foundation
import Regex
import SwiftyJSON

public class ParsingService {
    public init() {}

    private let tokenizer = Tokenizer()

    private func getJSONKeys(tokens: [String]) -> [JSONSubscriptType] {
        return tokens.map {
            if let intValue = Int($0) {
                return intValue
            } else {
                return $0
            }
        }
    }

    private func expand(index: Int, key: String, value: String, dataJSON: JSON) -> [(key: String, value: String)] {
        guard let keyMatch = Pattern.iterator.regex.allMatches(in: key).first(
            where: {
                $0.matchedString == "{{iterator#\(index)}}"
            }
        ) else {
            return [(key: key, value: value)]
        }

        let valueMatches = Pattern.iterator.regex.allMatches(in: value).filter {
            $0.matchedString == "{{iterator#\(index)}}"
        }

        guard let firstValueMatch = valueMatches.first else {
            return [(key: key, value: value)]
        }

        let croppedStr = value[...value.index(firstValueMatch.range.lowerBound, offsetBy: -2)]
        guard let dataRange = croppedStr.range(of: "{{data", options: .backwards) else {
            return [(key: key, value: value)]
        }
        var path = croppedStr[dataRange.upperBound...]
        if path.first == "." {
            _ = path.popFirst()
        }

        var jsonKeys: [JSONSubscriptType] = getJSONKeys(tokens: path.components(separatedBy: "."))
        if jsonKeys.count == 1 && (jsonKeys[0] as? String)?.isEmpty == true {
            jsonKeys = []
        }
        guard let count = dataJSON[jsonKeys].array?.count else {
            return [(key: key, value: value)]
        }

        var res: [(key: String, value: String)] = []
        for index in 0 ..< count {
            let newKey = key.replacingCharacters(in: keyMatch.range, with: "\(index)")
            var newValue = value
            for valueMatch in valueMatches.reversed() {
                newValue = newValue.replacingCharacters(in: valueMatch.range, with: "\(index)")
            }
            res.append((key: newKey, value: newValue))
        }

        return res
    }

    public func expandAllIndexes(key: String, value anyValue: Any, dataJSON: JSON) -> [(key: String, value: Any)] {
        guard let value = anyValue as? String else {
            return [(key: key, value: anyValue)]
        }

        var res: [(key: String, value: String)] = [(key: key, value: value)]
        let indexCount = Pattern.iterator.regex.allMatches(in: key).count

        for index in 0 ..< indexCount {
            var newRes: [(key: String, value: String)] = []
            for record in res {
                newRes += expand(index: index, key: record.key, value: record.value, dataJSON: dataJSON)
            }
            res = newRes
        }

        return res.map {
            (key: $0.key, value: $0.value as Any)
        }
    }

    func process(string: String, json: JSON) -> String {
        return tokenizer
            .tokenize(string: string)
            .extract(from: json)
    }

    func process(
        string: String,
        json: JSON,
        deserializerMap: ResponseDeserializerMap,
        action: String?,
        viewModel: ViewModelProtocol?
    ) throws -> Any {
        return try tokenizer
            .tokenize(string: string)
            .combine(
                json: json,
                deserializerMap: deserializerMap,
                action: action,
                viewModel: viewModel
            )
    }

    func process(string: String, action: String?, viewModel: ViewModelProtocol?) -> Any? {
        return tokenizer.tokenize(string: string).extract(fromAction: action, viewModel: viewModel)
    }

    private enum Pattern: String {
        case iterator = "\\{\\{iterator\\#[0-9]*\\}\\}"

        var regex: Regex {
            // swiftlint:disable:next force_try
            return try! Regex(string: self.rawValue, options: [.ignoreCase])
        }
    }
}
