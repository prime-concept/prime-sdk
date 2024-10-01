import Foundation
import SwiftyJSON

extension JSON {
    func extract(field: String) throws -> JSON {
        if self[field].exists() {
            return self[field]
        } else {
            throw MissingFieldError(fieldName: field)
        }
    }
}
