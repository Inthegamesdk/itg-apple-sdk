//
//  AVPlayerAdapter.swift
//  Inthegametv
//
//  Created by Daedalus on 26.07.2023.
//

import Foundation
import AVKit
#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif

open class ITGAVPlayerAdapter: NSObject, ITGPlayerAdapter {
    
    weak public var delegate: ITGPlayerAdapterDelegate?
    private var player: AVPlayer!
    private var playerViewController: AVPlayerViewController?
    private var seekTimer: Timer?
    
    public init(_ player: AVPlayer, playerViewController: AVPlayerViewController?, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.player = player
        self.playerViewController = playerViewController
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
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem))
        if player.currentItem != nil {
            playerViewController?.children.first(where: { String(describing: type(of: $0)) == "AVMobileChromelessControlsViewController" })?.view.removeObserver(self, forKeyPath: #keyPath(UIView.isHidden))
        }
    }
    
    open func setup() {
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.old, .new], context: nil)
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.old, .new], context: nil)
#if os(tvOS)
        if #available(tvOS 15.0, *) {
            let action = UIAction(title: "Menu", image: UIImage(named: "menu")) { [weak self] _ in
                self?.delegate?.menuButtonAction()
            }
            playerViewController?.transportBarCustomMenuItems = [action]
        }
#endif
        playerViewController?.player = player
        playerViewController?.showsPlaybackControls = true
#if os(tvOS)
        playerViewController?.playbackControlsIncludeInfoViews = false
#endif
        playerViewController?.videoGravity = .resizeAspect
    }
    
    open func getPlayerView() -> UIView? {
        return playerViewController?.view
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
    }
    
    open func pause() {
        player?.pause()
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
        playerViewController?.videoGravity = videoGravity
    }
    
    open func setSoundLevel(_ soundLevel: Float) {
        player.volume = soundLevel
    }
    
    open func getSoundLevel() -> Float {
        return player.volume
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.timeControlStatus), let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async { [weak self] in
                    guard let player = self?.player else { return }
                    let time = player.currentTime().seconds
                    self?.delegate?.videoPaused(time)
                    if newStatus == .playing {
                        self?.delegate?.videoPlaying(time)
                    }
                }
            }
        }
        if keyPath == #keyPath(AVPlayer.currentItem), let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? AVPlayerItem {
            NotificationCenter.default.addObserver(forName: AVPlayerItem.timeJumpedNotification, object: newValue, queue: OperationQueue.main) { [weak self]  (notification) in
                guard let player = self?.player else { return }
                self?.delegate?.videoPaused(player.currentTime().seconds)
                if player.timeControlStatus == .playing {
                    self?.seekTimer?.invalidate()
                    self?.seekTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: { (timer) in
                        self?.seekTimer = nil
                        if player.timeControlStatus == .playing {
                            let time = player.currentTime().seconds
                            self?.delegate?.videoPlaying(time)
                        }
                    })
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

