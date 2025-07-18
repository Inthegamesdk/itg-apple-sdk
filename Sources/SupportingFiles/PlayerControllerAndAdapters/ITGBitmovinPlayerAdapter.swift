//
//  Untitled.swift
//  Inthegametv
//
//  Created by ilya khymych on 20.03.2025.
//

import SwiftUI
import Foundation
import AVKit
import BitmovinPlayer
#if canImport(ITGPlayerViewController)
import ITGPlayerViewController
#endif


open class ITGBitmovinPlayerAdapter: NSObject, ITGPlayerAdapter {
    
    public var delegate: (any ITGPlayerAdapterDelegate)?
    var player: Player!
    var playerViewUIKit: PlayerView?
    var playerViewSwiftUI: VideoPlayerView?
    var playerViewController: AVPlayerViewController?
    var hostingController: UIHostingController<VideoPlayerView>?
    
    public init(_ player: Player, playerView: PlayerView, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.player = player
        self.playerViewUIKit = playerView
        self.delegate = delegate
        super.init()
        setup()
    }
    
    public init(_ player: Player, playerView: VideoPlayerView, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.player = player
        self.playerViewSwiftUI = playerView
        self.hostingController = UIHostingController(rootView: playerView)
        self.delegate = delegate
        super.init()
        setup()
    }
    
    public init(_ player: Player, playerViewController: AVPlayerViewController, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.player = player
        self.playerViewController = playerViewController
        self.delegate = delegate
        super.init()
        setup()
    }
    
    open func setup() {
        player.add(listener: self)
        DispatchQueue.main.async {
            self.playerViewUIKit?.add(listener: self)
        }
    }
    
    
    open func startVideo(_ url: URL) {
        player.load(sourceConfig: SourceConfig(url: url)!)
    }
    
    open func getPlayerView() -> UIView? {
        return playerViewUIKit ?? hostingController?.view ?? playerViewController?.view
    }
    
    open func getVideoResolution() -> CGSize {
        if let playerView = getPlayerView() {
            return ((playerView.deepSubviews() + [playerView]).compactMap({ [$0.layer] + $0.layer.deepSublayers() }).flatMap({ $0 }).first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer)?.videoRect.size ?? .zero
        }
        return .zero
    }
    
    open func isPlaying() -> Bool {
        return player.isPlaying
    }
    
    open func play() {
        player.play()
    }
    
    open func pause() {
        player.pause()
    }
    
    open func seek(_ time: TimeInterval) {
        player.seek(time: time)
    }
    
    open func getCurrentTime() -> TimeInterval {
        return player.currentTime
    }
    
    open func getVideoLength() -> TimeInterval {
        return player.duration
    }
    
    open func setVideoGravity(_ videoGravity: AVLayerVideoGravity) {
        DispatchQueue.main.async {
            if let playerViewController = self.playerViewController {
                playerViewController.videoGravity = videoGravity
            } else if let playerView = self.hostingController?.view {
                ((playerView.deepSubviews() + [playerView]).compactMap({ [$0.layer] + $0.layer.deepSublayers() }).flatMap({ $0 }).first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer)?.videoGravity = videoGravity
            } else {
                let scalingMode: ScalingMode
                switch videoGravity {
                case .resizeAspect:
                    scalingMode = ScalingMode.fit
                case .resizeAspectFill:
                    scalingMode = ScalingMode.zoom
                case .resize:
                    scalingMode = ScalingMode.stretch
                default:
                    return
                }
                self.playerViewUIKit?.scalingMode = scalingMode
            }
        }
    }
    
    open func setSoundLevel(_ soundLevel: Float) {
        player.volume = Int(soundLevel*100)
    }
    
    open func getSoundLevel() -> Float {
        return Float(Double(player.volume)/100)
    }
    
}

extension ITGBitmovinPlayerAdapter: PlayerListener {
    
    open func onPlaying(_ event: BitmovinPlayerCore.PlayingEvent, player: any Player) {
        delegate?.videoPlaying(getCurrentTime())
    }
    
    open func onPaused(_ event: BitmovinPlayerCore.PausedEvent, player: any Player) {
        delegate?.videoPaused(getCurrentTime(), userInitiated: true, isSeeking: false)
    }
    
    open func onPlaybackFinished(_ event: BitmovinPlayerCore.PlaybackFinishedEvent, player: any Player) {
        delegate?.videoPaused(getCurrentTime(), userInitiated: false, isSeeking: false)
    }
    
    open func onSeeked(_ event: BitmovinPlayerCore.SeekedEvent, player: any Player) {
        if isPlaying() {
            delegate?.videoPlaying(getCurrentTime())
        } else {
            delegate?.videoPaused(getCurrentTime(), userInitiated: false, isSeeking: true)
        }
    }

    open func onTimeShifted(_ event: BitmovinPlayerCore.TimeShiftedEvent, player: any Player) {
        if isPlaying() {
            delegate?.videoPlaying(getCurrentTime())
        } else {
            delegate?.videoPaused(getCurrentTime(), userInitiated: false, isSeeking: true)
        }
    }
    
    open func onStallStarted(_ event: BitmovinPlayerCore.StallStartedEvent, player: any Player) {
        delegate?.videoPaused(getCurrentTime(), userInitiated: false, isSeeking: false)
    }
    
    open func onStallEnded(_ event: BitmovinPlayerCore.StallEndedEvent, player: any Player) {
        if isPlaying() {
            delegate?.videoPlaying(getCurrentTime())
        } else {
            delegate?.videoPaused(getCurrentTime(), userInitiated: false, isSeeking: false)
        }
    }
    
}

extension ITGBitmovinPlayerAdapter: UserInterfaceListener {
    
    open nonisolated func onControlsHide(_ event: ControlsHideEvent, view: PlayerView) {
        delegate?.videoControllsVisibilityChanged(false)
    }
    
    open nonisolated func onControlsShow(_ event: ControlsShowEvent, view: PlayerView) {
        delegate?.videoControllsVisibilityChanged(true)
    }
    
}

