import Foundation

public extension Data {
    func convertToPrettyPrintedString() -> NSString {
        if let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let string = NSString(data: pretty, encoding: String.Encoding.utf8.rawValue) {
            return string
        } else {
            if let string = NSString(data: self, encoding: String.Encoding.utf8.rawValue) {
                return string
            }
        }

        return ""
    }
}
