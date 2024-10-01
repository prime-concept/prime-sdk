import UIKit

public class KeyboardAvoidingCollectionView: UICollectionView {
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        beginListeningToKeyboard()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        beginListeningToKeyboard()
    }

    private var originalContentInsetBottom: CGFloat?
    private var originalScrollInsetBottom: CGFloat?

    private func beginListeningToKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardAny = userInfo[UIResponder.keyboardFrameEndUserInfoKey],
              let keyboardValue = keyboardAny as? NSValue else {
            return
        }

        if originalContentInsetBottom == nil {
            originalContentInsetBottom = contentInset.bottom
        }

        if originalScrollInsetBottom == nil {
            originalScrollInsetBottom = scrollIndicatorInsets.bottom
        }

        var keyboardFrame: CGRect = keyboardValue.cgRectValue
        keyboardFrame = self.convert(keyboardFrame, from: nil)

        let insetBottom = keyboardFrame.size.height + (originalContentInsetBottom ?? 0)

        contentInset.bottom += insetBottom
        scrollIndicatorInsets.bottom += insetBottom
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        contentInset.bottom = originalContentInsetBottom ?? 0
        scrollIndicatorInsets.bottom = originalScrollInsetBottom ?? 0
    }
}
