import Foundation
import SwiftyJSON

struct TokenizedString: Equatable {
    let tokens: [Token]
    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func combine(
        json: JSON,
        deserializerMap: ResponseDeserializerMap,
        action: String?,
        viewModel: ViewModelProtocol?
    ) throws -> Any {
        let unmergedResult = try tokens.map { token in
            try fetchTokenResult(
                token: token,
                json: json,
                deserializerMap: deserializerMap,
                action: action,
                viewModel: viewModel
            )
        }

        if unmergedResult.count == 1, let result = unmergedResult.first {
            if let result = result as? Substring {
                return String(result)
            } else {
                return result
            }
        } else {
            return unmergedResult.reduce("") {
                if let unwrapped = $1 {
                    return $0 + String(describing: unwrapped)
                } else {
                    return $0 + String(describing: $1)
                }
            }
        }
    }

    private func fetchTokenResult(
        token: Token,
        json: JSON,
        deserializerMap: ResponseDeserializerMap,
        action: String?,
        viewModel: ViewModelProtocol?
    ) -> Any? {
        switch token {
        case .plainString(let string):
            return string
        case .data(let processor):
            return processor.process(json: json).object
        case .action(let processor):
            guard let action = action else {
                fatalError("Misusage")
            }
            return processor.process(storageName: action)
        case .substitution(let processor):
            return processor.process(substitutions: deserializerMap.substitutions, json: json)?.object
        case .sender(let processor):
            guard let viewModel = viewModel else {
                fatalError("Should have view model")
            }
            return processor.process(viewModel: viewModel)
        case .shared(let processor):
            return try processor.process()
        }
    }

    func extract(from json: JSON) -> String {
        guard let token = tokens.first, tokens.count == 1 else {
            fatalError("No tokens")
        }

        if case .data(let processor) = token, let string = processor.process(json: json).string {
            return string
        } else {
            fatalError("Wrong token")
        }
    }

    func extract(fromAction action: String?, viewModel: ViewModelProtocol?) -> Any? {
        let unmergedResult: [Any] = tokens.compactMap { token in
            switch token {
            case .action(let processor):
                guard let action = action else {
                    return nil
                }
                return processor.process(storageName: action)
            case .sender(let processor):
                guard
                    let viewModel = viewModel
                else {
                    return nil
                }
                return processor.process(viewModel: viewModel)
            case .plainString(let string):
                return String(string)
            case .shared(let processor):
                return processor.process()
            default:
                fatalError("UnexpectedToken")
            }
        }

        if unmergedResult.isEmpty {
            return nil
        } else if unmergedResult.count == 1, let result = unmergedResult.first {
            return result
        } else {
            return unmergedResult.reduce("") { $0 + String(describing: $1) }
        }
    }

//    func extract(fromAction action: String, viewModel: ViewModelProtocol?) -> Any? {
//        let result: Any? = extract(fromAction: action, viewModel: viewModel)
//        // TODO: - bug with optional string packaged inside any somewhere
//        if let result = result as? String {
//            return result
//        } else if let result = result {
//            return String(describing: result)
//        } else {
//            return nil
//        }
//    }
}
