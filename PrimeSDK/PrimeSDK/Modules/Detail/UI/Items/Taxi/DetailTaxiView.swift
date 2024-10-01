import UIKit

final class TaxiFakeButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.white.withAlphaComponent(0.35)
            } else {
                self.backgroundColor = .clear
            }
        }
    }
}

final class DetailTaxiView: UIView, URLAppOpenable {
    @IBOutlet private weak var yandexTaxiArrowImageView: UIImageView!
    @IBOutlet private weak var yandexTaxiLabel: UILabel!

    @IBAction func onYandexTaxiButtonClick(_ sender: Any) {
        guard let path = yandexTaxiURL,
              let url = URL(string: path)
        else {
            return
        }

        self.onTaxiButtonClick?()
        self.applicationOpenURL(url: url)
    }

    var onTaxiButtonClick: (() -> Void)?

    var yandexTaxiURL: String?

    var yandexTaxiPrice: Int? {
        didSet {
            if let price = yandexTaxiPrice {
                yandexTaxiLabel.text = "RideOnYandex \(price) rub"
            } else {
                yandexTaxiLabel.text = "RideOnYandex"
            }
        }
    }

    func setup(viewModel: DetailTaxiViewModel) {
        yandexTaxiPrice = viewModel.yandexTaxiPrice
        yandexTaxiURL = viewModel.yandexTaxiURL
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.yandexTaxiPrice = nil

        self.yandexTaxiArrowImageView.image = #imageLiteral(resourceName: "arrow_right").withRenderingMode(.alwaysTemplate)
        self.yandexTaxiArrowImageView.tintColor = UIColor(red: 0.45, green: 0.77, blue: 0.8, alpha: 1)
        self.yandexTaxiLabel.font = UIFont.font(of: 12, weight: .semibold)
    }
}
