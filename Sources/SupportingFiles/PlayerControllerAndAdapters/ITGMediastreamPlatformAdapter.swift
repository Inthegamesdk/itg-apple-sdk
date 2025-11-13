//
//  ITG.swift
//  Inthegametv
//
//  Created by ilya khymych on 04.04.2025.
//

import AVKit
#if canImport(ITGPlayerViewController)
import ITGPlayerViewController
#endif

public protocol ITGMediastreamPlatform {
    
    var view: UIView! { get }
    var playerLayer: AVPlayerLayer? { get }
    var playerViewController: AVPlayerViewController? { get }
    var volume: Int { get set }
    func play()
    func pause()
    func getResolution() -> String
    func checkIsPlaying() -> Bool
    func seekTo(_ time: Double)
    func getCurrentTime() -> Int64
    func getDuration() -> Int
    
}

public protocol ITGMediastreamPlatformEventManager {
    
    func listenTo(eventName: String, action: @escaping () -> ())
    func listenTo(eventName: String, action: @escaping (Any?) -> ())
    func removeListeners(eventNameToRemoveOrNil: String?)
    
}

open class ITGMediastreamPlatformAdapter: ITGPlayerAdapter {
    
    weak public var delegate: ITGPlayerAdapterDelegate?
    var mdstrm: ITGMediastreamPlatform
    var eventsManger: ITGMediastreamPlatformEventManager
    
    public init(_ mdstrm: ITGMediastreamPlatform, eventsManger: ITGMediastreamPlatformEventManager, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.mdstrm = mdstrm
        self.eventsManger = eventsManger
        setup()
    }
    
    deinit {
        eventsManger.removeListeners(eventNameToRemoveOrNil: nil)
    }
    
    open func setup() {
        eventsManger.listenTo(eventName: "play") {
            self.delegate?.videoPlaying(self.getCurrentTime())
        }
        eventsManger.listenTo(eventName: "pause", action: {
            self.delegate?.videoPaused(self.getCurrentTime(), userInitiated: true, isSeeking: false)
        })
        eventsManger.listenTo(eventName: "seek") {
            if self.isPlaying() {
                self.delegate?.videoPlaying(self.getCurrentTime())
            } else {
                self.delegate?.videoPaused(self.getCurrentTime(), userInitiated: false, isSeeking: false)
            }
        }
        eventsManger.listenTo(eventName: "finish", action: {
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
        return Double(mdstrm.getCurrentTime())/1000
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
        return Float(mdstrm.volume)/100
    }
    
}
