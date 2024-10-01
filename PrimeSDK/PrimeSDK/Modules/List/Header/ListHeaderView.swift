import UIKit

final class ListHeaderView: UICollectionReusableView, NibLoadable, ViewReusable {
    @IBOutlet private weak var infoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.infoLabel.font = UIFont.font(of: 16, weight: .semibold)
    }

    var text: String? {
        didSet {
            infoLabel.text = text
        }
    }

    func setup(with info: String?) {
        text = info
    }
}
