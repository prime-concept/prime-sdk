import UIKit

@IBDesignable
public final class SpinnerView: UIView {
    struct Appearance {
        var colorSpinner = UIColor(
            red: 0.77,
            green: 0.77,
            blue: 0.77,
            alpha: 1.0
        )
        var colorBackground = UIColor(
            red: 0.95,
            green: 0.95,
            blue: 0.95,
            alpha: 1.0
        )

        var lineWidthRatio: CGFloat = 0.12
    }

    var appearance = Appearance()

    private var isAnimationInited = false

    private var circleSpinner: CAShapeLayer?
    private var circleBackground: CAShapeLayer?

    override public func layoutSubviews() {
        super.layoutSubviews()

        if !isAnimationInited {
            isAnimationInited = true
            DispatchQueue.main.async { [weak self] in
                self?.setupAnimation()
            }
        }

        let frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.size.width,
            height: bounds.size.height
        )
        circleSpinner?.frame = frame
        circleBackground?.frame = frame
    }

    private func setupAnimation() {
        let path = UIBezierPath()
        path.addArc(
            withCenter: CGPoint(
                x: bounds.size.width / 2,
                y: bounds.size.height / 2
            ),
            radius: bounds.size.width / 2,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )

        let circleBackground = CAShapeLayer()
        circleBackground.backgroundColor = nil
        circleBackground.fillColor = nil
        circleBackground.strokeColor = appearance.colorBackground.cgColor
        circleBackground.lineWidth = appearance.lineWidthRatio * bounds.size.width
        circleBackground.backgroundColor = nil
        circleBackground.path = path.cgPath
        circleBackground.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.size.width,
            height: bounds.size.height
        )

        let circleSpinner = CAShapeLayer()
        circleSpinner.backgroundColor = nil
        circleSpinner.fillColor = nil
        circleSpinner.strokeColor = appearance.colorSpinner.cgColor
        circleSpinner.lineWidth = appearance.lineWidthRatio * bounds.size.width
        circleSpinner.backgroundColor = nil
        circleSpinner.path = path.cgPath
        circleSpinner.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.size.width,
            height: bounds.size.height
        )
        circleSpinner.lineCap = .round

        let strokeStartFirstAnimation = CASpringAnimation(keyPath: "strokeStart")
        strokeStartFirstAnimation.initialVelocity = 0
        strokeStartFirstAnimation.mass = 1
        strokeStartFirstAnimation.stiffness = 50
        strokeStartFirstAnimation.damping = 14
        strokeStartFirstAnimation.duration = 1.0
        strokeStartFirstAnimation.fromValue = 0.0
        strokeStartFirstAnimation.toValue = 0.75
        strokeStartFirstAnimation.repeatCount = 0
        strokeStartFirstAnimation.autoreverses = false
        strokeStartFirstAnimation.beginTime = 0.0
        strokeStartFirstAnimation.isRemovedOnCompletion = false
        strokeStartFirstAnimation.fillMode = CAMediaTimingFillMode.forwards

        let strokeEndSecondAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeEndSecondAnimation.duration = 0.4
        strokeEndSecondAnimation.fromValue = 1.0
        strokeEndSecondAnimation.toValue = -0.25
        strokeEndSecondAnimation.repeatCount = 0
        strokeEndSecondAnimation.autoreverses = false
        strokeEndSecondAnimation.beginTime = 2.5
        strokeEndSecondAnimation.isRemovedOnCompletion = false
        strokeEndSecondAnimation.fillMode = CAMediaTimingFillMode.forwards

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        // speed property not working here, so let's change angle value
        rotationAnimation.byValue = Float.pi * 6
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.duration = 3.6
        rotationAnimation.autoreverses = false

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [
            rotationAnimation,
            strokeStartFirstAnimation,
            strokeEndSecondAnimation
        ]
        groupAnimation.duration = 3.6
        groupAnimation.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.linear
        )
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        groupAnimation.autoreverses = false

        circleSpinner.add(groupAnimation, forKey: "animation")

        layer.addSublayer(circleSpinner)
        layer.insertSublayer(circleBackground, at: 0)

        self.circleSpinner = circleSpinner
        self.circleBackground = circleBackground
    }
}
