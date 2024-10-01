import UICollectionViewLeftAlignedLayout
import UIKit

class MovieScheduleView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    let itemHeight: CGFloat = 40
    let itemWidth: CGFloat = 60
    let spacing: CGFloat = 5

    var schedules: [KinohodTicketsBookerScheduleViewModel.Schedule] = []

    var onSelect: ((KinohodTicketsBookerScheduleViewModel.Schedule) -> Void)?

    private var skeletonView: MovieScheduleSkeletonView = .fromNib()

    var isSkeletonShown: Bool = false {
        didSet {
            skeletonView.translatesAutoresizingMaskIntoConstraints = false
            if isSkeletonShown {
                self.skeletonView.showAnimatedGradientSkeleton()
                setElements(hidden: true)
                self.skeletonView.isHidden = false
            } else {
                self.skeletonView.isHidden = true
                setElements(hidden: false)
                self.skeletonView.hideSkeleton()
            }
        }
    }

    private func setElements(hidden: Bool) {
        titleLabel.isHidden = hidden
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(skeletonView)
        skeletonView.alignToSuperview()
        isSkeletonShown = false

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            UINib(nibName: "MovieScheduleTimeCollectionViewCell", bundle: .primeSdk),
            forCellWithReuseIdentifier: "MovieScheduleTimeCollectionViewCell"
        )
        collectionView.isScrollEnabled = false
        let layout = UICollectionViewLeftAlignedLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        collectionView.setCollectionViewLayout(layout, animated: false)
        self.setupFonts()
    }

    func update(
        viewModel: KinohodTicketsBookerScheduleViewModel.ScheduleRow,
        isSkeletonShown: Bool,
        onSelect: ((KinohodTicketsBookerScheduleViewModel.Schedule) -> Void)?
    ) {
        titleLabel.text = viewModel.group.name
        self.isSkeletonShown = isSkeletonShown
        self.schedules = viewModel.schedules
        self.onSelect = onSelect
        collectionView.reloadData()

        updateHeight()
    }

    private func updateHeight() {
        let width = UIScreen.main.bounds.width - 30
        let rowColumnCountFloat = ((width + spacing) / (itemWidth + spacing)).rounded(.down)
        let rowColumnCount = Int(rowColumnCountFloat)

        let rowCount = Int((Float(schedules.count) / Float(rowColumnCount)).rounded(.up))

        let height = itemHeight * CGFloat(rowCount) + spacing * (CGFloat(rowCount) - 1)
        collectionViewHeight.constant = height
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 14, weight: .medium)
    }
}

extension MovieScheduleView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return schedules.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MovieScheduleTimeCollectionViewCell",
                for: indexPath
            ) as? MovieScheduleTimeCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.update(viewModel: schedules[indexPath.item])
        cell.isSkeletonShown = isSkeletonShown
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if schedules[indexPath.item].minPrice != 0 {
            onSelect?(schedules[indexPath.item])
        }
    }
}
