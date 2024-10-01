import Foundation
import SnapKit

extension ButtonShadowBackgroundView {
    struct Appearance {
        var capInsets = UIEdgeInsets(top: 0, left: 10, bottom: 15, right: 10)
        var alignmentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}

final class ButtonShadowBackgroundView: UIControl {
    let appearance: Appearance

    private lazy var shadowBackgroundView: UIImageView = {
        // swiftlint:disable force_unwrapping
        let image = UIImage(
            named: "shadow-button-resizable-background", in: .primeSdk, compatibleWith: nil
        )!.resizableImage(withCapInsets: self.appearance.capInsets)
        // swiftlint:enable force_unwrapping
        let view = UIImageView(image: image)
        view.backgroundColor = .clear
        return view
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ButtonShadowBackgroundView: ProgrammaticallyDesignable {
    func setupView() {
        self.isUserInteractionEnabled = false
    }

    func addSubviews() {
        self.addSubview(self.shadowBackgroundView)
    }

    func makeConstraints() {
        self.shadowBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.alignmentInsets)
        }
    }
}
