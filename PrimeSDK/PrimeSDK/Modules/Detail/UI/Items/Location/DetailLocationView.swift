import UIKit

final class DetailLocationView: UIView {
    private static let radius: CGFloat = 8

    @IBOutlet private weak var addressView: UIView!
    @IBOutlet private weak var taxiView: UIView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var taxiLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!

    private var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    private var location: GeoCoordinate? {
        didSet {
            addressView.isHidden = location == nil
        }
    }

    private var address: String = "" {
        didSet {
            addressView.isHidden = address.isEmpty
            addressLabel.text = address
        }
    }

    private var taxiTitle: String = "" {
        didSet {
            taxiLabel.text = taxiTitle
        }
    }

    private var price: Int? {
        didSet {
            if let price = price {
                priceLabel.text = "\(fromTitle) \(price) \(priceEndingTitle)"
            }
        }
    }

    private var priceEndingTitle = ""
    private var fromTitle = ""

    private var yandexTaxiUrl: String? {
        didSet {
            taxiView.isHidden = yandexTaxiUrl == nil
        }
    }

    var onTaxi: (() -> Void)?
    var onAddress: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupView()
        self.setupFonts()
    }

    private func setupFonts() {
        self.addressLabel.font = UIFont.font(of: 11, weight: .semibold)
        self.taxiLabel.font = UIFont.font(of: 11, weight: .medium)
        self.titleLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.priceLabel.font = UIFont.font(of: 12, weight: .semibold)
    }

    private func setupView() {
        titleLabel.text = ""
        addressView?.layer.cornerRadius = DetailLocationView.radius
        taxiView?.layer.cornerRadius = DetailLocationView.radius
        addressView.dropShadowForView()
        taxiView.dropShadowForView()
        addTap()
    }

    private func addTap() {
        let showMapTap = UITapGestureRecognizer(target: self, action: #selector(adreessTap))
        addressView.addGestureRecognizer(showMapTap)
        let taxiTap = UITapGestureRecognizer(target: self, action: #selector(onTaxiTap))
        taxiView.addGestureRecognizer(taxiTap)
    }

    @objc
    private func onTaxiTap() {
        onTaxi?()
    }

    @objc
    private func adreessTap() {
        onAddress?()
    }
}

extension DetailLocationView {
    func setup(viewModel: DetailLocationViewModel) {
        title = viewModel.title
        taxiTitle = viewModel.taxiTitle
        priceEndingTitle = viewModel.priceEndingTitle
        fromTitle = viewModel.fromTitle
        address = viewModel.address
        price = viewModel.taxiPrice
        yandexTaxiUrl = viewModel.taxiURL
        location = viewModel.location
    }
}
