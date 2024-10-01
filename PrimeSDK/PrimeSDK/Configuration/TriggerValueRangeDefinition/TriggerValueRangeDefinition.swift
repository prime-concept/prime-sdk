import Foundation
import SwiftyJSON

/**
 Depicts a range of values uniquely identified as one range
 */
protocol TriggerValueRangeDefinition {
    init(parametersJSON: JSON) throws
    func contains(value: Int) -> Bool
    var id: String { get }
}
