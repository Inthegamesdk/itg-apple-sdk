//
//  AVPlayerAdapter.swift
//  Inthegametv
//
//  Created by Daedalus on 26.07.2023.
//

import Foundation
import AVKit

open class ITGAVPlayerAdapter: NSObject, ITGPlayerAdapter {
    
    weak public var delegate: ITGPlayerAdapterDelegate?
    public var player: AVPlayer! {
        didSet {
            removeObserver(oldValue)
            registerObservers()
        }
    }
    private var playerViewController: AVPlayerViewController?
    private var playerView: UIView?
    private var seekTimer: Timer?
    private var isSeeking: Bool = false
    private var timeJumpedTime: TimeInterval?
    
    public init(_ player: AVPlayer, playerViewController: AVPlayerViewController, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.player = player
        self.playerViewController = playerViewController
        self.delegate = delegate
        super.init()
#if os(tvOS)
        self.playerViewController?.delegate = self
#endif
        setup()
    }
    
    public init(_ player: AVPlayer, playerView: UIView, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.player = player
        self.playerView = playerView
        self.delegate = delegate
        super.init()
#if os(tvOS)
        self.playerViewController?.delegate = self
#endif
        setup()
    }
    
    deinit {
        seekTimer?.invalidate()
        seekTimer = nil
        removeObserver(player)
        if player.currentItem != nil, let playerViewController {
            playerViewController.children.first(where: { String(describing: type(of: $0)) == "AVMobileChromelessControlsViewController" })?.view.removeObserver(self, forKeyPath: #keyPath(UIView.isHidden))
        }
    }
    
    open func setup() {
        registerObservers()
        playerViewController?.player = player
        playerViewController?.showsPlaybackControls = true
#if os(tvOS)
        playerViewController?.playbackControlsIncludeInfoViews = false
#endif
        playerViewController?.videoGravity = .resizeAspect
    }
    
    open func removeObserver(_ player: AVPlayer?) {
        player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.timeJumpedNotification, object: nil)
    }
    
    open func registerObservers() {
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timeJumped), name: AVPlayerItem.timeJumpedNotification, object: nil)
    }
    
    open func getPlayerView() -> UIView? {
        return playerViewController?.view ?? playerView
    }
    
    open func getVideoResolution() -> CGSize {
        return player?.currentItem?.presentationSize ?? .zero
    }
    
    open func startVideo(_ url: URL) {
        playerViewController?.children.first(where: { String(describing: type(of: $0)) == "AVMobileChromelessControlsViewController" })?.view.addObserver(self, forKeyPath: #keyPath(UIView.isHidden), options: [.old, .new], context: nil)
        player.replaceCurrentItem(with: AVPlayerItem(asset: AVAsset(url: url)))
        player.play()
   }
    
    open func play() {
        player.play()
#if os(tvOS)
        playerViewController?.showsPlaybackControls = true
        delegate?.videoControllsVisibilityChanged(false)
#endif
    }
    
    open func pause() {
        player?.pause()
#if os(tvOS)
        playerViewController?.showsPlaybackControls = false
        playerViewController?.showsPlaybackControls = true
        delegate?.videoControllsVisibilityChanged(false)
#endif
    }
    
    open func isPlaying() -> Bool {
        return player.timeControlStatus == .playing
    }
    
    open func seek(_ time: TimeInterval) {
        player?.seek(to: CMTime(value: CMTimeValue(time), timescale: 1), toleranceBefore: CMTime(value: CMTimeValue(0.1), timescale: 1), toleranceAfter: CMTime(value: CMTimeValue(0.1), timescale: 1), completionHandler: { [weak self] _ in
            if self?.player?.timeControlStatus == .paused {
                self?.player?.play()
                self?.player?.pause()
            }
        })
    }
    
    open func getCurrentTime() -> TimeInterval {
        return player.currentTime().seconds
    }
    
    open func getVideoLength() -> TimeInterval {
        return player.currentItem?.duration.seconds ?? 0
    }
    
    open func setVideoGravity(_ videoGravity: AVLayerVideoGravity) {
        if let playerViewController {
            playerViewController.videoGravity = videoGravity
        } else if let playerView, let playerLayer = (playerView.deepSubviews() + [playerView]).compactMap({ [$0.layer] + $0.layer.deepSublayers() }).flatMap({ $0 }).first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer {
            playerLayer.videoGravity = videoGravity
        }
    }
    
    open func setSoundLevel(_ soundLevel: Float) {
        player.volume = soundLevel
    }
    
    open func getSoundLevel() -> Float {
        return player.volume
    }
    
    
    @objc open func timeJumped(_ notification: NSNotification) {
        if notification.object as? NSObject == player.currentItem {
            isSeeking = true
            timeJumpedTime = player.currentTime().seconds
            delegate?.videoPaused(player.currentTime().seconds, userInitiated: false, isSeeking: isSeeking == true)
            if player.timeControlStatus == .playing {
                seekTimer?.invalidate()
                let player = player!
                seekTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: { (timer) in
                    self.seekTimer = nil
                    if player == self.player, player.timeControlStatus == .playing {
                        self.delegate?.videoPlaying(player.currentTime().seconds)
                        self.isSeeking = false
                    }
                })
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.timeControlStatus), let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async { [weak self] in
                    guard let player = self?.player else { return }
                    let time = player.currentTime().seconds
                    self?.delegate?.videoPaused(time, userInitiated: newStatus == .paused && self?.getCurrentTime() != self?.getVideoLength(), isSeeking: self?.isSeeking == true && self?.timeJumpedTime != time)
                    if newStatus == .playing {
                        self?.delegate?.videoPlaying(time)
                        self?.isSeeking = false
                    }
                }
            }
        }
        if keyPath == #keyPath(UIView.isHidden), let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Bool {
            delegate?.videoControllsVisibilityChanged(!newValue)
        }
    }
    
}

#if os(tvOS)
extension ITGAVPlayerAdapter: AVPlayerViewControllerDelegate {
    
    open func playerViewController(_ playerViewController: AVPlayerViewController, willTransitionToVisibilityOfTransportBar visible: Bool, with coordinator: AVPlayerViewControllerAnimationCoordinator) {
        delegate?.videoControllsVisibilityChanged(visible)
    }
    
}
#endif

