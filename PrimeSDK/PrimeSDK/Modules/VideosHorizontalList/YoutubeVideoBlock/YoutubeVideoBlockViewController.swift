import AVKit
import Foundation
import Nuke
import UIKit
import YoutubeKit

final class YoutubeVideoBlockViewController: UIViewController {
    var viewModel: YoutubeVideoBlockViewModel? {
        didSet {
            guard !(self.viewModel?.isDummy ?? true) else {
                return
            }

            self.titleLabel.text = self.viewModel?.title

            if let author = self.viewModel?.author, !author.isEmpty {
                self.authorLabel.text = author
            } else {
                self.authorLabel.isHidden = true
                self.titleLabel.snp.remakeConstraints { make in
                    make.leading.equalToSuperview().offset(15)
                    make.trailing.equalTo(self.shareButton.snp.leading).offset(-15)
                    make.bottom.equalToSuperview().offset(-15)
                }
            }

            if oldValue?.previewVideoURL != self.viewModel?.previewVideoURL &&
                self.viewModel?.previewVideoURL != nil {
                self.loadVideo()
                self.videoView.isHidden = false
                self.thumbnailImageView.isHidden = true
            } else if viewModel?.previewVideoURL == nil {
                self.videoView.isHidden = true
                self.thumbnailImageView.isHidden = false
                self.loadImage()
            }

            switch self.viewModel?.status ?? YoutubeVideoLiveState.none {
            case .none:
                self.statusContainerView.isHidden = true
            case .live:
                self.statusContainerView.isHidden = false
                self.statusImageView.image = UIImage(named: "video-status-live", in: .primeSdk, compatibleWith: nil)
                self.statusLabel.text = NSLocalizedString("LiveVideoStatus", bundle: .primeSdk, comment: "")
            case .upcoming:
                self.statusContainerView.isHidden = false
                self.statusImageView.image = UIImage(
                    named: "video-status-notstarted",
                    in: .primeSdk,
                    compatibleWith: nil
                )
                self.statusLabel.text = NSLocalizedString("UpcomingVideoStatus", bundle: .primeSdk, comment: "")
            }

            if self.viewModel?.shouldShowPlayButton ?? false {
                self.view.addSubview(self.playBackgroundView)
                self.playBackgroundView.addSubview(self.overlayButton)
                self.playBackgroundView.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 55, height: 55))
                    make.center.equalToSuperview()
                }
            } else {
                self.view.insertSubview(self.overlayButton, belowSubview: self.spinnerView)
            }

            self.overlayButton.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    var isSkeletonShown: Bool = false {
        didSet {
            if self.isSkeletonShown {
                self.skeletonView.showAnimatedGradientSkeleton()
                self.setElements(hidden: true)
                self.skeletonView.isHidden = false
            } else {
                self.setElements(hidden: false)
                self.skeletonView.isHidden = true
                self.skeletonView.hideSkeleton()
            }
        }
    }


    private lazy var skeletonView = YoutubeVideoBlockSkeletonView()

    private lazy var videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 18, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 12, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var overlayButton: UIButton = {
        let button = UIButton()
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        button.addTarget(
            self,
            action: #selector(onVideoTap),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle(nil, for: .normal)
        button.setImage(
            UIImage(
                named: "share",
                in: .primeSdk,
                compatibleWith: nil
            )?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )

        button.tintColor = .white

        button.addTarget(
            self,
            action: #selector(onShareButtonTap),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var statusContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var statusImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var spinnerView: SpinnerView = {
        let spinnerView = SpinnerView()
        spinnerView.isHidden = true
        spinnerView.appearance.colorBackground = .clear
        return spinnerView
    }()

    private lazy var playBackgroundView: BlurView = {
        let view = BlurView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 27.5
        return view
    }()

    private lazy var playIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "video - play - button", in: .primeSdk, compatibleWith: nil)
        return imageView
    }()

    private var player: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?

    private var previousState: YTSwiftyPlayerState?

    private var youtubePlayer: YTSwiftyPlayer?

    override func loadView() {
        let view = UIView()

        [
            self.skeletonView,
            self.videoView,
            self.thumbnailImageView,
            self.dimView,
            self.titleLabel,
            self.authorLabel,
            self.statusContainerView,
            self.spinnerView,
            self.shareButton
        ].forEach(view.addSubview)

        [
            self.statusImageView,
            self.statusLabel
        ].forEach(statusContainerView.addSubview)

        self.skeletonView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        playBackgroundView.addSubview(playIconImageView)

        playIconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 15, height: 20))
            make.top.bottom.equalToSuperview().inset(17.5)
            make.leading.equalToSuperview().offset(22.5)
            make.trailing.equalToSuperview().offset(-17.5)
        }

        self.videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.spinnerView.snp.makeConstraints { make in
            make.height.width.equalTo(35)
            make.center.equalToSuperview()
        }

        self.authorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.trailing.equalTo(self.shareButton.snp.leading).offset(-15)
            make.height.equalTo(14)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalTo(self.authorLabel.snp.top).offset(-5)
            make.trailing.equalTo(self.shareButton.snp.leading).offset(-15)
        }

        self.shareButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(34)
        }

        self.statusContainerView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(15)
        }

        self.statusImageView.snp.makeConstraints { make in
            make.height.width.equalTo(12)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }

        self.statusLabel.snp.makeConstraints { make in
            make.height.equalTo(19)
            make.leading.equalTo(statusImageView.snp.trailing).offset(8)
            make.top.bottom.trailing.equalToSuperview()
        }

        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.clipsToBounds = true

        self.view = view
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = self.videoView.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isSkeletonShown = false
    }

    // MARK: - Public

    func pauseVideo() {
        self.player?.pause()
    }

    func playVideo() {
        self.player?.play()
    }

    // MARK: - Private

    private func setElements(hidden: Bool) {
        self.view.subviews
            .filter { ![self.thumbnailImageView, self.spinnerView, self.skeletonView].contains($0) }
            .forEach { $0.isHidden = hidden }
    }

    @objc
    private func onShareButtonTap() {
        guard
            let id = viewModel?.id,
            let url = URL(string: "https://youtube.com/watch?v=\(id)")
        else {
            return
        }

        let shareVC = UIActivityViewController(activityItems: [url], applicationActivities: [])
        present(shareVC, animated: true)
    }

    @objc
    private func onVideoTap() {
        self.playBackgroundView.isHidden = true
        self.spinnerView.isHidden = false
        self.addYoutubeVideoPlayer()
    }

    private func loadImage() {
        guard
            let viewModel = self.viewModel,
            let imagePath = viewModel.previewImageURL,
            let url = URL(string: imagePath)
        else {
            return
        }
        Nuke.loadImage(with: url, into: self.thumbnailImageView)
    }

    private func loadVideo() {
        guard
            let viewModel = viewModel,
            let videoPath = viewModel.previewVideoURL,
            let url = URL(
                string: videoPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            )
        else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            if self.player == nil {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                let player = AVQueuePlayer(playerItem: playerItem)

                self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)

                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.videoView.bounds
                playerLayer.videoGravity = .resizeAspectFill

                self.player = player
                self.playerLayer = playerLayer
                self.videoView.layer.addSublayer(playerLayer)
                player.isMuted = true
                player.play()
            }
        }
    }

    private func addYoutubeVideoPlayer() {
        self.youtubePlayer?.removeFromSuperview()
        guard let videoID = viewModel?.id else {
            return
        }
        let player = YTSwiftyPlayer(
            playerVars: [
                .videoID(videoID),
                .playsInline(false),
                .showFullScreenButton(false),
                .autoplay(true),
                .showRelatedVideo(false)
            ]
        )
        self.youtubePlayer = player

        player.autoplay = true
        player.delegate = self

        self.view.addSubview(player)
        player.snp.makeConstraints { make in
            make.height.width.equalTo(0)
        }

        player.loadPlayer()
    }
}


extension YoutubeVideoBlockViewController: YTSwiftyPlayerDelegate {
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
//        print("Player did change state from \(previousState) to \(state)")
        guard let prev = previousState else {
            previousState = state
            return
        }

        if prev == .buffering && state == .paused {
            youtubePlayer?.playVideo()
        }

        if state == .playing {
            spinnerView.isHidden = true
        }

        if prev == .playing && state == .paused {
            self.playBackgroundView.isHidden = false
            self.playVideo()
        }

        previousState = state
    }
}
