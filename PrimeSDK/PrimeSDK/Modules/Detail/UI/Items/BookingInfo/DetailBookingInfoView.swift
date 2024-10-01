import PromiseKit
import SnapKit
import UIKit

extension Notification.Name {
    static let onBookingStatusUpdate = Notification.Name("onBookingStatusUpdate")
}

class DetailBookingInfoView: UIView {
    var apiService: APIServiceProtocol?
    var onLayoutUpdate: (() -> Void)?
    var onPresent: ((UIViewController) -> Void)?

    private var viewModel: DetailBookingInfoViewModel?
    private let spacing = 15

    private lazy var shadowedContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var verticalContainerView: ContainerStackView = {
        let view = ContainerStackView()
        view.axis = .vertical
        view.spacing = 15
        return view
    }()

    private lazy var bookingNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.text = NSLocalizedString("BookingNumber", bundle: .primeSdk, comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private lazy var cancellationPolicyContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var cancellationPolicyButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        button.setTitle(
            NSLocalizedString("CancellationPolicyButtonTitle", bundle: .primeSdk, comment: ""),
            for: .normal
        )
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(cancellationPolicyPressed), for: .touchUpInside)
        return button
    }()

    init() {
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()
    }

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = self.backgroundColor ?? .white
            self.bookingNumberLabel.textColor = color.isLight() ? .black : .white
            self.verticalContainerView.views.forEach { $0.backgroundColor = self.backgroundColor }
        }
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.shadowedContainer.layer.masksToBounds = false
        self.shadowedContainer.layer.cornerRadius = 8
        self.shadowedContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.shadowedContainer.layer.shadowPath = UIBezierPath(
            roundedRect: self.shadowedContainer.bounds,
            cornerRadius: self.shadowedContainer.layer.cornerRadius
        ).cgPath
        self.shadowedContainer.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.shadowedContainer.layer.shadowOpacity = 1.0
        self.shadowedContainer.layer.shadowRadius = 5.0
    }

    @objc
    func cancellationPolicyPressed() {
        guard let url = viewModel?.cancellationPolicyURL else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func update(with viewModel: DetailBookingInfoViewModel?, shouldLoadContent: Bool = true) {
        guard let viewModel = viewModel else {
            return
        }
        self.viewModel = viewModel
        self.bookingNumberLabel.text = "\(NSLocalizedString("BookingNumber", bundle: .primeSdk, comment: ""))\(viewModel.bookingNumber)"
        self.backgroundColor = viewModel.backgroundColor
        self.shadowedContainer.backgroundColor = viewModel.backgroundColor

        self.verticalContainerView.resetViews()
        let dateRowView = DetailBookingInfoRowView(
            title: NSLocalizedString("DateAndTime", bundle: .primeSdk, comment: ""),
            text: viewModel.displayingDateString
        )
        self.verticalContainerView.addView(view: dateRowView)

        if !viewModel.guests.isEmpty {
            self.verticalContainerView.addView(view: createSeparator())
            let guestsRowView = DetailBookingInfoExpandableGuestsView(guests: viewModel.guests)
            guestsRowView.onLayoutUpdate = self.onLayoutUpdate
            self.verticalContainerView.addView(view: guestsRowView)
        }

        if !viewModel.options.isEmpty {
            self.verticalContainerView.addView(view: createSeparator())
            let reservationOptionsView = DetailBookingInfoRowView(
                title: NSLocalizedString("Reservation options", bundle: .primeSdk, comment: ""),
                text: viewModel.options
            )
            self.verticalContainerView.addView(view: reservationOptionsView)
        }

        if !viewModel.note.isEmpty {
            self.verticalContainerView.addView(view: createSeparator())
            let notesView = DetailBookingInfoRowView(
                title: NSLocalizedString("Notes", bundle: .primeSdk, comment: ""),
                text: viewModel.note
            )
            self.verticalContainerView.addView(view: notesView)
        }

        if let newDate = viewModel.newDate,
           let newTime = viewModel.newTime,
           viewModel.bookingStatus == "IN_CHANGE" {
            let suggestionView = DetailBookingInfoSuggestionView(
                clubName: viewModel.clubName,
                newDate: newDate,
                newTime: newTime
            )
            self.verticalContainerView.addView(view: suggestionView)
        }


        self.verticalContainerView.addView(view: self.cancellationPolicyContainerView)

        switch viewModel.bookingStatus {
        case "IN_CHANGE":
            let actionView = InChangeBookingActionView()
            actionView.onAccept = { [weak self] in
                guard let viewModel = self?.viewModel else {
                    return
                }
                viewModel.sdkManager.bookingDelegate?.changeBookingStatus(bookingID: viewModel.id, newStatus: "CONFIRMED")
            }
            actionView.onDecline = { [weak self] in
                guard let viewModel = self?.viewModel else {
                    return
                }
                viewModel.sdkManager.bookingDelegate?.changeBookingStatus(bookingID: viewModel.id, newStatus: "CANCEL")
            }
            self.verticalContainerView.addView(view: actionView)
        default:
            if viewModel.availableStatuses.contains("CANCEL") {
                let actionView = CancelBookingActionView()
                actionView.onCancel = { [weak self] in
                    let isLate = viewModel.visitDateTimeUTC.timeIntervalSinceNow <= 60 * 60 * 2
                    self?.presentCancelAlert(isLate: isLate)
                }
                self.verticalContainerView.addView(view: actionView)
            }
        }

        self.verticalContainerView.setNeedsLayout()
        self.verticalContainerView.layoutIfNeeded()
        self.onLayoutUpdate?()

        if shouldLoadContent {
            self.load()
        }
    }

    private func presentCancelAlert(isLate: Bool) {
        let alert = UIAlertController(
            title: isLate ? "" : NSLocalizedString("BookingCancelAlertTitle", bundle: .primeSdk, comment: ""),
            message: isLate ?
                NSLocalizedString("BookingCancelLateAlertMessage", bundle: .primeSdk, comment: "") :
                NSLocalizedString("BookingCancelAlertMessage", bundle: .primeSdk, comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Not now", bundle: .primeSdk, comment: ""),
                style: .default,
                handler: nil
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", bundle: .primeSdk, comment: ""),
                style: .destructive,
                handler: { [weak self] _ in
                    guard let viewModel = self?.viewModel else {
                        return
                    }
                    viewModel.sdkManager.bookingDelegate?.changeBookingStatus(
                        bookingID: viewModel.id,
                        newStatus: isLate ? "CANCEL_LATE" : "CANCEL"
                    )
                }
            )
        )
        self.onPresent?(alert)
    }

    private func addSubviews() {
        [
            self.shadowedContainer
        ].forEach {
            self.addSubview($0)
        }
        [
            self.bookingNumberLabel,
            self.verticalContainerView
        ].forEach {
            self.shadowedContainer.addSubview($0)
        }
        [
            self.cancellationPolicyButton
        ].forEach {
            self.cancellationPolicyContainerView.addSubview($0)
        }
    }

    private func makeConstraints() {
        self.shadowedContainer.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(15)
        }

        self.bookingNumberLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(10)
        }

        self.verticalContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.bookingNumberLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }

        self.cancellationPolicyButton.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
        }
    }

    private func load() {
        guard
            let viewModel = self.viewModel,
            let loadAction = viewModel.loadAction,
            let apiService = self.apiService
        else {
            return
        }

        loadAction.request.inject(action: loadAction.name, viewModel: viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: viewModel)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: viewModel.sdkManager.apiDelegate
        ).promise.done { [weak self] deserializedViewMap in
            guard let self = self else {
                throw GuardError.selfUnpack
            }

            self.viewModel?.update(valueForAttributeID: deserializedViewMap.valueForAttributeID)
            self.update(with: self.viewModel, shouldLoadContent: false)
            self.notifyAboutStatusChange()
        }.catch { [weak self] _ in
            //Do something with an error
        }
    }

    private func notifyAboutStatusChange() {
        guard let viewModel = viewModel else {
            return
        }
        NotificationCenter.default.post(
            name: .onBookingStatusUpdate,
            object: nil,
            userInfo: [
                "id": viewModel.clubID,
                "status": viewModel
                    .bookingStatus
                    .lowercased()
                    .replacingOccurrences(of: "_", with: " ")
                    .capitalized
            ]
        )
    }

    private func createSeparator(insets: CGFloat = 15) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(hex: 0xeaeaea)
        containerView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(insets)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        return containerView
    }

    enum GuardError: Error {
        case selfUnpack
    }
}
