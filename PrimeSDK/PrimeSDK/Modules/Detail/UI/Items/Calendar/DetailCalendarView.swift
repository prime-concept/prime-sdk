import UIKit

final class DetailCalendarView: UIView {
    private static let dayItemSize = CGSize(width: 43, height: 60)
    private static let dayItemSpacing: CGFloat = 5.0
    private static let daysInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    @IBOutlet private weak var daysCollectionView: UICollectionView!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var emptyViewLabel: UILabel!
    @IBOutlet private weak var firstDateButton: UIButton!

    private var previousTableViewHeight = CGFloat(0)
    private var selectedDayIndex: Int = 0

    private var viewModel: DetailCalendarViewModel?

    var onLayoutUpdate: (() -> Void)?
    /// Returns event
    var onEventClick: ((DetailCalendarViewModel.EventItem) -> Void)?

    @IBAction func onFirstDateButtonClick(_ sender: Any) {
        guard let viewModel = viewModel else {
            return
        }

        self.daysCollectionView.scrollToItem(
            at: IndexPath(item: viewModel.firstDateIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
        self.selectItem(index: viewModel.firstDateIndex)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupEmptyView()
        setupTableView()
        setupCollectionView()
    }

    func setup(viewModel: DetailCalendarViewModel) {
        self.viewModel = viewModel
        selectItem(index: 0)
        emptyViewLabel.text = viewModel.noEventText

        firstDateButton.setTitle(viewModel.nearestDateString, for: .normal)

        DispatchQueue.main.async { [weak self] in
            self?.onLayoutUpdate?()
        }
    }

    private func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.clipsToBounds = false

        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass: DetailCalendarTableViewCell.self)
    }

    private func setupEmptyView() {
        emptyView.isHidden = true
        emptyViewLabel.text = viewModel?.noEventText
        self.emptyViewLabel.font = UIFont.font(of: 15)
        firstDateButton.tintColor = .black
    }

    private func setupCollectionView() {
        daysCollectionView.register(cellClass: DetailCalendarDayCollectionViewCell.self)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = DetailCalendarView.dayItemSize
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = DetailCalendarView.dayItemSpacing
        layout.sectionInset = DetailCalendarView.daysInsets
        daysCollectionView.setCollectionViewLayout(layout, animated: true)
        daysCollectionView.showsHorizontalScrollIndicator = false

        daysCollectionView.dataSource = self
        daysCollectionView.delegate = self
    }

    private func selectItem(index: Int) {
        selectedDayIndex = index

        tableView.reloadData()
        daysCollectionView.reloadData()
        updateHeight()
    }

    private func updateHeight() {
        tableView.layoutIfNeeded()

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let calendarHeight: CGFloat = 140.0
            let newHeight = max(
                calendarHeight,
                strongSelf.tableView.contentSize.height
            )

            if strongSelf.previousTableViewHeight != newHeight {
                strongSelf.previousTableViewHeight = newHeight

                let paddingForBottomButton: CGFloat = 65.0
                strongSelf.heightConstraint.constant = newHeight
                    + paddingForBottomButton
                strongSelf.onLayoutUpdate?()
            }
        }
    }
}

extension DetailCalendarView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel,
              !viewModel.events[selectedDayIndex].isEmpty else {
            emptyView.isHidden = false
            return 0
        }

        emptyView.isHidden = true
        return viewModel.events[selectedDayIndex].count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: DetailCalendarTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let eventItems = getEventItemsForSelectedDay()

        cell.bottomText = eventItems[indexPath.row].title
        cell.topText = eventItems[indexPath.row].timeString

        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.shouldShowSeparator = !isLastCell
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let eventItems = getEventItemsForSelectedDay()

        onEventClick?(eventItems[indexPath.row])
    }

    private func getEventItemsForSelectedDay() -> [DetailCalendarViewModel.EventItem] {
        guard let viewModel = viewModel,
              let eventItems = viewModel.events[safe: selectedDayIndex] else {
            fatalError("Cell's count > 0, but empty viewModel")
        }

        return eventItems
    }
}

extension DetailCalendarView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel?.days.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: DetailCalendarDayCollectionViewCell = collectionView.dequeueReusableCell(
            for: indexPath
        )

        guard let dayItem = viewModel?.days[safe: indexPath.row] else {
            fatalError("View model has invalid data")
        }

        cell.dayItemView.topText = dayItem.dayOfWeek
        cell.dayItemView.mainText = dayItem.dayNumber
        cell.dayItemView.bottomText = dayItem.month

        cell.dayItemView.state = dayItem.hasEvents ? .withEvents : .withoutEvents
        if indexPath.row == selectedDayIndex {
            cell.dayItemView.state = .selected
        }

        cell.dayItemView.onClick = { [weak self] in
            self?.selectItem(index: indexPath.row)
        }
        return cell
    }
}
