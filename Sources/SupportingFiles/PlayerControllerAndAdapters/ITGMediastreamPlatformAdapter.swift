//
//  ITG.swift
//  Inthegametv
//
//  Created by ilya khymych on 04.04.2025.
//

import AVKit
#if os(tvOS)
import MediastreamPlatformSDKAppleTV
#elseif os(iOS) 
import MediastreamPlatformSDKiOS
#endif

open class ITGMediastreamPlatformAdapter: ITGPlayerAdapter {
    
    weak public var delegate: ITGPlayerAdapterDelegate?
    var mdstrm: MediastreamPlatformSDK
    
    public init(_ mdstrm: MediastreamPlatformSDK, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.mdstrm = mdstrm
        setup()
    }
    
    deinit {
        mdstrm.events.removeListeners(eventNameToRemoveOrNil: nil)
    }
    
    open func setup() {
        mdstrm.events.listenTo(eventName: "play") {
            self.delegate?.videoPlaying(self.getCurrentTime())
        }
        mdstrm.events.listenTo(eventName: "pause", action: {
            self.delegate?.videoPaused(self.getCurrentTime(), userInitiated: true, isSeeking: false)
        })
        mdstrm.events.listenTo(eventName: "seek") {
            if self.isPlaying() {
                self.delegate?.videoPlaying(self.getCurrentTime())
            } else {
                self.delegate?.videoPaused(self.getCurrentTime(), userInitiated: false, isSeeking: false)
            }
        }
        mdstrm.events.listenTo(eventName: "finish", action: {
            self.delegate?.videoPaused(self.getCurrentTime(), userInitiated: false, isSeeking: false)
        })
    }
    
    open func startVideo(_ url: URL) {
 
    }
    
    open func getPlayerView() -> UIView? {
        mdstrm.view
    }
    
    open func getVideoResolution() -> CGSize {
        let resolution = mdstrm.getResolution()
        let components = resolution.split(separator: "x")
        if components.count == 2, let width = Double(components.first!), let height = Double(components.last!) {
            return CGSize(width: width, height: height )
        } else {
            return CGSizeZero
        }
    }
    
    open func isPlaying() -> Bool {
        mdstrm.checkIsPlaying()
    }
    
    open func play() {
        mdstrm.play()
    }
    
    open func pause() {
        mdstrm.pause()
    }
    
    open func seek(_ time: TimeInterval) {
        mdstrm.seekTo(time)
    }
    
    open func getCurrentTime() -> TimeInterval {
        return Double(mdstrm.getCurrentTime()/1000)
    }
    
    open func getVideoLength() -> TimeInterval {
        return Double(mdstrm.getDuration())
    }
    
    open func setVideoGravity(_ videoGravity: AVLayerVideoGravity) {
        if let playerViewController = mdstrm.playerViewController {
            playerViewController.videoGravity = videoGravity
        } else {
            mdstrm.playerLayer?.videoGravity = videoGravity
        }
    }
    
    open func setSoundLevel(_ soundLevel: Float) {
        mdstrm.volume = Int(soundLevel*100)
    }
    
    open func getSoundLevel() -> Float {
        return Float(mdstrm.volume/100)
    }
    
}
