import Nuke
import UIKit

final class ImageCarouselView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        return pageControl
    }()

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.isUserInteractionEnabled = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true

        addSubview(scrollView)
        scrollView.addSubview(stackView)
        addSubview(backgroundView)
        addSubview(pageControl)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.attachEdges(to: self)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.attachEdges(to: scrollView)
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.attachEdges(to: self)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            pageControl.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 5.5
            ).isActive = true
        } else {
            let constant = UIApplication.shared.statusBarFrame.height + 5.5
            pageControl.topAnchor.constraint(
                equalTo: topAnchor,
                constant: constant
            ).isActive = true
        }
        pageControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    private func resetStackViewSubviews() {
        for view in stackView.subviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func setImages(with url: [URL]) {
        resetStackViewSubviews()
        pageControl.numberOfPages = url.count
        for index in 0..<url.count {
            // Image for carousel
            let imageView = UIImageView()
            stackView.addArrangedSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            loadImage(url: url[index], view: imageView)
        }
    }

    private func loadImage(url: URL, view: UIImageView) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions.cacheOptions,
            into: view
        )
    }
}

extension ImageCarouselView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left * 2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        pageControl.currentPage = Int(roundedIndex)
    }
}
