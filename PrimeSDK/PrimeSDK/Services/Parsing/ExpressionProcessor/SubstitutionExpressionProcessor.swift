import Foundation
import SwiftyJSON

public struct SubstitutionExpressionProcessor: Equatable {
    let name: String
    let index: Int

    init(name: String, index: Int) {
        self.name = name
        self.index = index
    }

    private func getJSONKeys(tokenString: String) -> [JSONSubscriptType] {
        let tokens = tokenString.components(separatedBy: ".")

        return tokens.map {
            if let intValue = Int($0) {
                return intValue
            } else {
                return $0
            }
        }
    }

    func process(substitutions: [Substitution], json: JSON) -> JSON? {
        guard
            let substitution = substitutions.first(where: { name == $0.name })
        else {
            return nil
        }

        let sourceFieldTokens = getJSONKeys(tokenString: substitution.source) +
            [index] +
            getJSONKeys(tokenString: substitution.sourceField)
        let sourceFieldValue = json[sourceFieldTokens]

        let targetJson = json[getJSONKeys(tokenString: substitution.target)]

        for targetCandidate in targetJson.arrayValue {
            let candidateFieldValue = targetCandidate[getJSONKeys(tokenString: substitution.targetField)]
            if candidateFieldValue == sourceFieldValue {
                return targetCandidate[getJSONKeys(tokenString: substitution.extractField)]
            }
        }

        return nil
    }
}
