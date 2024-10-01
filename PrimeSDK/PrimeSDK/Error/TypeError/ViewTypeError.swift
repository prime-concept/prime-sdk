import Foundation

public class ViewTypeError: PrimeSDKError {
    private var viewType: String

    init(viewType: String) {
        self.viewType = viewType
    }

    override public var localizedDescription: String {
        if viewType.isEmpty {
            return "View type is empty or isn't declared"
        } else {
            return "Unknown view type \"\(viewType)\". Please check the documentation."
        }
    }
}
