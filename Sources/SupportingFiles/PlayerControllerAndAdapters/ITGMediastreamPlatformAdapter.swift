//
//  ITG.swift
//  Inthegametv
//
//  Created by ilya khymych on 04.04.2025.
//

import AVKit
#if os(tvOS) && canImport(MediastreamPlatformSDKAppleTV)
import MediastreamPlatformSDKAppleTV
#elseif os(iOS) && canImport(MediastreamPlatformSDKiOS)
import MediastreamPlatformSDKiOS
#endif
#if canImport(ITGPlayerViewController)
import ITGPlayerViewController
#endif

class ITGMediastreamPlatformAdapter: ITGPlayerAdapter {
    
    weak public var delegate: ITGPlayerAdapterDelegate?
    var mdstrm: MediastreamPlatformSDK
    
    public init(_ mdstrm: MediastreamPlatformSDK, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.mdstrm = mdstrm
        setup()
    }
    
    deinit {
        mdstrm.events.removeListeners(eventNameToRemoveOrNil: nil)
    }
    
    func setup() {
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
    
    func startVideo(_ url: URL) {
 
    }
    
    func getPlayerView() -> UIView? {
        mdstrm.view
    }
    
    func getVideoResolution() -> CGSize {
        let resolution = mdstrm.getResolution()
        let components = resolution.split(separator: "x")
        if components.count == 2, let width = Double(components.first!), let height = Double(components.last!) {
            return CGSize(width: width, height: height )
        } else {
            return CGSizeZero
        }
    }
    
    func isPlaying() -> Bool {
        mdstrm.checkIsPlaying()
    }
    
    func play() {
        mdstrm.play()
    }
    
    func pause() {
        mdstrm.pause()
    }
    
    func seek(_ time: TimeInterval) {
        mdstrm.seekTo(time)
    }
    
    func getCurrentTime() -> TimeInterval {
        return Double(mdstrm.getCurrentTime()/1000)
    }
    
    func getVideoLength() -> TimeInterval {
        return Double(mdstrm.getDuration())
    }
    
    func setVideoGravity(_ videoGravity: AVLayerVideoGravity) {
        if let playerViewController = mdstrm.playerViewController {
            playerViewController.videoGravity = videoGravity
        } else {
            mdstrm.playerLayer?.videoGravity = videoGravity
        }
    }
    
    func setSoundLevel(_ soundLevel: Float) {
        mdstrm.volume = Int(soundLevel*100)
    }
    
    func getSoundLevel() -> Float {
        return Float(mdstrm.volume/100)
    }
    
}
