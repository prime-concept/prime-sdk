import TagListView
import UIKit

final class DetailTagsView: UIView {
    private lazy var tagsListView: TagListView = {
        let view = TagListView()
        view.alignment = .left
        view.borderColor = .clear
        view.borderWidth = 0
        view.cornerRadius = 10
        view.tagBackgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        view.textColor = UIColor.black
        view.textFont = UIFont.font(of: 12, weight: .semibold)
        view.isUserInteractionEnabled = false
        // Space between tags
        view.marginX = 5
        view.marginY = 5
        // Space between text and tag background view
        view.paddingX = 8
        view.paddingY = 5
        return view
    }()

    private var isInit = false

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: tagsListView.bounds.height
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        defer {
            invalidateIntrinsicContentSize()
        }

        guard !isInit else {
            return
        }

        addSubview(tagsListView)
        tagsListView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                tagsListView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                tagsListView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
                tagsListView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
                tagsListView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
            ]
        )
    }
}

extension DetailTagsView {
    func setup(viewModel: DetailTagsViewModel) {
        tagsListView.removeAllTags()
        tagsListView.addTags(viewModel.items)

        tagsListView.textColor = viewModel.textColor ?? .black
    }
}
