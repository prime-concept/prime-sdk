import Foundation

public extension Dictionary {
    func convertToPrettyPrintedString() -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) else {
            return ""
        }

        let jsonString = String(data: jsonData, encoding: .ascii)
        return jsonString ?? ""
    }
}
