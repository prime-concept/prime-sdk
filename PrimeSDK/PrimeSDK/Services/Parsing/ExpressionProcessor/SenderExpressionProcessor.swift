import Foundation

struct SenderExpressionProcessor: Equatable {
    private let name: String

    init(name: String) {
        self.name = name
    }

    func process(viewModel: ViewModelProtocol) -> Any? {
        if let attributeValue = viewModel.attributes[name] {
            return attributeValue
        } else {
            return nil
//            fatalError("Not found")
        }
    }
}
