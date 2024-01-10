//
//  File.swift
//  Inthegametv
//
//  Created by Daedalus on 01.08.2023.
//

import Foundation
import KalturaPlayer
import PlayKit
import AVKit
#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif

open class ITGKalturaPlayerAdapter: NSObject, ITGPlayerAdapter {
    
    weak public var delegate: ITGPlayerAdapterDelegate?
    private var player: KalturaPlayer!
    private var playerControlsVisibilityBlock: (()->Bool)?
    
    public init(_ player: KalturaPlayer, playerControlsVisibilityBlock: (()->Bool)?, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.player = player
        super.init()
        setup()
    }
    
    deinit {
        player.removeObserver(self, events: [PlayerEvent.playing, PlayerEvent.pause, PlayerEvent.ended, PlayerEvent.play.stopped])
        playerControlsVisibilityBlock = nil
    }
    
    open func setup() {
        player.addObserver(self, events: [PlayerEvent.playing, PlayerEvent.pause, PlayerEvent.ended, PlayerEvent.play.stopped]) { [weak self] event in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch event {
                case is PlayerEvent.Playing:
                    self.delegate?.videoPlaying(self.getCurrentTime())
                default:
                    self.delegate?.videoPaused(self.getCurrentTime())
                }
            }
        }
    }
    
    open func startVideo(_ url: URL) {
        player.setMedia(PKMediaEntry("video", sources: [PKMediaSource("video", contentUrl: url)]))
        play()
    }
    
    open func getPlayerView() -> UIView? {
        return player.view
    }
    
    open func getVideoResolution() -> CGSize {
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
        player.seek(to: time)
    }
    
    open func getCurrentTime() -> TimeInterval {
        return player.currentTime
    }
    
    open func getVideoLength() -> TimeInterval {
        return player.duration
    }
    
    open func setVideoGravity(_ videoGravity: AVLayerVideoGravity) {
        player.view?.contentMode = videoGravity == .resize ? .scaleToFill : .scaleAspectFit
    }
    
    open func setSoundLevel(_ soundLevel: Float) {
        player.volume = soundLevel
    }
    
    open func getSoundLevel() -> Float {
        return player.volume
    }
    
}
