import UIKit

/// Representation of appearance scheme (colors, icons, etc)
public struct Theme {
    /// Colors of given theme
    public var palette: ThemePalette

    /// Images of given theme
    public var imageSet: ThemeImageSet

    /// Default theme
    public static var `default` = Theme(
        palette: DefaultPalette(),
        imageSet: DefaultImageSet()
    )

    public init(palette: ThemePalette, imageSet: ThemeImageSet) {
        self.palette = palette
        self.imageSet = imageSet
    }

    // MARK: - Inner declaration

    private class DefaultPalette: ThemePalette {
        init() { }
    }
    private class DefaultImageSet: ThemeImageSet {
        init() { }
    }
}

// MARK: - Palette

private extension UIColor {
    static let defaultBlue = UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1)
}

/// Container for colors of some Theme
public protocol ThemePalette {
    /// App main color
    var accent: UIColor { get }

    /// Secondary color
    var secondaryColor: UIColor { get }

    /// Quiz colors
    var quizGradientStart: UIColor { get }
    var quizGradientEnd: UIColor { get }
    var quizAnswerSuccessGradientStart: UIColor { get }
    var quizAnswerSuccessGradientEnd: UIColor { get }
    var quizAnswerErrorGradientStart: UIColor { get }
    var quizAnswerErrorGradientEnd: UIColor { get }
    var quizAnswerResultGradientStart: UIColor { get }
    var quizAnswerResultGradientEnd: UIColor { get }
    var quizOnboardingGradientEnd: UIColor { get }
}

extension ThemePalette {
    var accent: UIColor { .blue }
    var secondaryColor: UIColor { accent }

    var quizGradientStart: UIColor { .red }
    var quizGradientEnd: UIColor { .black }

    var quizAnswerSuccessGradientStart: UIColor { .green }
    var quizAnswerSuccessGradientEnd: UIColor { .green }

    var quizAnswerErrorGradientStart: UIColor { .red }
    var quizAnswerErrorGradientEnd: UIColor { .red }

    var quizAnswerResultGradientStart: UIColor { .blue }
    var quizAnswerResultGradientEnd: UIColor { .blue }

    var quizOnboardingGradientEnd: UIColor { .blue }
}

// MARK: - ImageSet

/// Container for images of some Theme
public protocol ThemeImageSet {
    /// Cinema
    var cinemaTileFavoriteNormal: UIImage { get }
    var cinemaTileFavoriteSelected: UIImage { get }
}

extension ThemeImageSet {
    var cinemaTileFavoriteNormal: UIImage {
        UIImage()
    }
    var cinemaTileFavoriteSelected: UIImage {
        UIImage()
    }
}
