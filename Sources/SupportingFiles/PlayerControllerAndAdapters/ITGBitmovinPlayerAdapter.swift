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
#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
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
        super.init()
        setup()
    }
    
    public init(_ player: Player, playerView: VideoPlayerView, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.player = player
        self.playerViewSwiftUI = playerView
        self.hostingController = UIHostingController(rootView: playerView)
        super.init()
        setup()
    }
    
    public init(_ player: Player, playerViewController: AVPlayerViewController, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.player = player
        self.playerViewController = playerViewController
        super.init()
        setup()
    }
    
    public func setup() {
        player.add(listener: self)
        DispatchQueue.main.async {
            self.playerViewUIKit?.add(listener: self)
        }
    }
    
    
    public func startVideo(_ url: URL) {
        player.load(sourceConfig: SourceConfig(url: url)!)
    }
    
    public func getPlayerView() -> UIView? {
        return playerViewUIKit ?? hostingController?.view ?? playerViewController?.view
    }
    
    public func getVideoResolution() -> CGSize {
        if let playerView = getPlayerView() {
            return ((playerView.deepSubviews() + [playerView]).compactMap({ [$0.layer] + $0.layer.deepSublayers() }).flatMap({ $0 }).first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer)?.videoRect.size ?? .zero
        }
        return .zero
    }
    
    public func isPlaying() -> Bool {
        return player.isPlaying
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func seek(_ time: TimeInterval) {
        player.seek(time: time)
    }
    
    public func getCurrentTime() -> TimeInterval {
        return player.currentTime
    }
    
    public func getVideoLength() -> TimeInterval {
        return player.duration
    }
    
    public func setVideoGravity(_ videoGravity: AVLayerVideoGravity) {
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
    
    public func setSoundLevel(_ soundLevel: Float) {
        player.volume = Int(soundLevel*100)
    }
    
    public func getSoundLevel() -> Float {
        return Float(Double(player.volume)/100)
    }
    
}

extension ITGBitmovinPlayerAdapter: PlayerListener {
    
    public func onPlaying(_ event: BitmovinPlayerCore.PlayingEvent, player: any Player) {
        delegate?.videoPlaying(getCurrentTime())
    }
    
    public func onPaused(_ event: BitmovinPlayerCore.PausedEvent, player: any Player) {
        delegate?.videoPaused(getCurrentTime(), userInitiated: true, isSeeking: false)
    }
    
    public func onSeeked(_ event: BitmovinPlayerCore.SeekedEvent, player: any Player) {
        if isPlaying() {
            delegate?.videoPlaying(getCurrentTime())
        } else {
            delegate?.videoPaused(getCurrentTime(), userInitiated: false, isSeeking: true)
        }
    }

    public func onTimeShifted(_ event: BitmovinPlayerCore.TimeShiftedEvent, player: any Player) {
        if isPlaying() {
            delegate?.videoPlaying(getCurrentTime())
        } else {
            delegate?.videoPaused(getCurrentTime(), userInitiated: false, isSeeking: true)
        }
    }
    
    public func onStallStarted(_ event: BitmovinPlayerCore.StallStartedEvent, player: any Player) {
        delegate?.videoPaused(getCurrentTime(), userInitiated: false, isSeeking: false)
    }
    
    public func onStallEnded(_ event: BitmovinPlayerCore.StallEndedEvent, player: any Player) {
        if isPlaying() {
            delegate?.videoPlaying(getCurrentTime())
        } else {
            delegate?.videoPaused(getCurrentTime(), userInitiated: false, isSeeking: false)
        }
    }
    
}

extension ITGBitmovinPlayerAdapter: UserInterfaceListener {
    
    public nonisolated func onControlsHide(_ event: ControlsHideEvent, view: PlayerView) {
        delegate?.videoControllsVisibilityChanged(false)
    }
    
    public nonisolated func onControlsShow(_ event: ControlsShowEvent, view: PlayerView) {
        delegate?.videoControllsVisibilityChanged(true)
    }
    
}

