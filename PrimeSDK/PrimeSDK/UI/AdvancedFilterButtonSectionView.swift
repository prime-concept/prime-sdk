import UIKit

public final class AdvancedFilterButtonSectionView: UIView {
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(clearButton)
        stack.addArrangedSubview(applyButton)
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.spacing = 5
        stack.backgroundColor = .clear
        return stack
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Clear", bundle: .primeSdk, comment: ""), for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.font(of: 16, weight: .semibold)
        return button
    }()

    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Apply", bundle: .primeSdk, comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.font(of: 16, weight: .semibold)
        return button
    }()

    private lazy var gradientBackgroundView: GradientContainerView = {
        let view = GradientContainerView()
        view.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(1).cgColor
        ]
        return view
    }()

	private var themeProvider: ThemeProvider?

    public var onClearTap: (() -> Void)?
    public var onApplyTap: (() -> Void)?

    public init(frame: CGRect = .zero, shouldShowClear: Bool = false) {
        super.init(frame: frame)

        clearButton.isHidden = !shouldShowClear

        backgroundColor = .clear
        setupSubviews()

        clearButton.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)

        self.themeProvider = ThemeProvider(themeUpdatable: self)
    }

    // swiftlint:disable unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // swiftlint:enable unavailable_function

    private func setupSubviews() {
        addSubview(gradientBackgroundView)
        gradientBackgroundView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        gradientBackgroundView.addSubview(buttonStackView)

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-10)
        }

        [self.clearButton, self.applyButton].forEach {
            $0.layer.cornerRadius = 8
            $0.snp.makeConstraints { make in
                make.height.equalTo(45)
            }
        }
    }

    @objc
    private func onButtonTap(_ button: UIButton) {
        if button == clearButton {
            onClearTap?()
        } else {
            onApplyTap?()
        }
    }
}

extension AdvancedFilterButtonSectionView: ThemeUpdatable {
    public func update(with theme: Theme) {
        self.clearButton.setTitleColor(theme.palette.accent, for: .normal)
        self.applyButton.backgroundColor = theme.palette.accent
    }
}
