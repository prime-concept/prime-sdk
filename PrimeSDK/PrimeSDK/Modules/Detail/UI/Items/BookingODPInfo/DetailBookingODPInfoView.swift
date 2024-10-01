import SnapKit
import UIKit

final class DetailBookingODPInfoView: UIView {
    private enum Appearance {
        static let cornerRadius = CGFloat(8)
        static let border = UIColor(red: 0.945, green: 0.835, blue: 0.545, alpha: 1)
        static let background = UIColor(red: 0.945, green: 0.835, blue: 0.545, alpha: 0.2)
        static let title = UIColor.black
    }

    private lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.title
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.text = NSLocalizedString("BookingODPInfo", bundle: .primeSdk, comment: "")
        return label
    }()

    var onLayoutUpdate: (() -> Void)?

    init() {
        super.init(frame: .zero)
        self.addEmpty()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addEmpty() {
        self.snp.removeConstraints()

        let contentView = UIView()
        self.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(0.5)
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.onLayoutUpdate?()
    }

    /// Add constraints
    func makeConstraints() {
        self.snp.removeConstraints()
        let contentView = UIView()
        contentView.backgroundColor = Appearance.background
        contentView.layer.cornerRadius = Appearance.cornerRadius
        contentView.layer.borderColor = Appearance.border.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.masksToBounds = true

        self.addSubview(contentView)

        contentView.addSubview(self.titlelabel)
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-15)
        }

        self.titlelabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(15)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        self.onLayoutUpdate?()
    }

    func setup(viewModel: DetailBookingODPInfoViewModel) {
        guard let clubID = viewModel.clubID else {
            addEmpty()
            return
        }

        viewModel.sdkManager?.bookingDelegate?.canBookClub(clubID: clubID).done { result in
            result.canBook ? self.addEmpty() : self.makeConstraints()
        }.catch { _ in
            self.addEmpty()
        }
    }
}
