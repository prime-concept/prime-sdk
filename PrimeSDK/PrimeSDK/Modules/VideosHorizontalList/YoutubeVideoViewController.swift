import Foundation
import SnapKit
import YoutubeKit

class YoutubeVideoViewController: UIViewController, YTSwiftyPlayerDelegate {
    var videoID: String?
    var player: YTSwiftyPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadVideo()
    }

    private func loadVideo() {
        guard let videoID = videoID else {
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
        self.player = player

        player.autoplay = false
        player.delegate = self

        self.view.addSubview(player)
        player.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        player.loadPlayer()
    }
}
