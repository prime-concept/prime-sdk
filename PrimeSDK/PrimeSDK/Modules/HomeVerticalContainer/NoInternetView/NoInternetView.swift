import UIKit

final class NoInternetView: UIView {
    @IBOutlet private weak var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        //TODO: Localize
        self.textLabel.text = "Ой-ой. Что-то пошло не так :(\nПроверьте подключение к интернету и попробуйте еще раз"
        self.textLabel.font = UIFont.font(of: 16)
    }
}
