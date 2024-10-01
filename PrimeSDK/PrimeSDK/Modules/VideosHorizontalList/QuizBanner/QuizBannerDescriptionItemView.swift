import Foundation

class QuizBannerDescriptionItemView: UIView {
    lazy var backgroundGradientContainerView: GradientContainerView = {
        let view = GradientContainerView()
        view.isHorizontal = true
        view.colors = [
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        return view
    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 12, weight: .semibold)
        label.textColor = .white
        return label
    }()

    init(text: String) {
        super.init(frame: CGRect.zero)
        setUp()
        self.label.text = text
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp() {
        self.backgroundColor = .clear

        [
            self.backgroundGradientContainerView,
            self.label
        ].forEach(self.addSubview)

        backgroundGradientContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
    }
}
