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

@objc public protocol ITGMediastreamPlatform {
    
    var view: UIView! { get }
    var playerLayer: AVPlayerLayer? { get }
    var playerViewController: AVPlayerViewController? { get }
    var volume: Int { get set }
    @objc func play()
    @objc func pause()
    @objc func getResolution() -> String
    @objc func checkIsPlaying() -> Bool
    @objc func seekTo(_ time: Double)
    @objc func getCurrentTime() -> Int64
    @objc func getDuration() -> Int64
    
}

@objc public protocol ITGMediastreamPlatformEventManager {
    
    @objc func listenTo(eventName: String, action: @escaping () -> ())
    
}

open class ITGMediastreamAdapter: ITGPlayerAdapter {
    
    weak public var delegate: ITGPlayerAdapterDelegate?
    var mdstrm: ITGMediastreamPlatform
    var eventsManger: ITGMediastreamPlatformEventManager
    var view: UIView?
    
    public init(_ mdstrm: ITGMediastreamPlatform, eventsManger: ITGMediastreamPlatformEventManager, customVideoView: UIView? = nil, delegate: ITGPlayerAdapterDelegate? = nil) {
        self.mdstrm = mdstrm
        self.eventsManger = eventsManger
        self.view = customVideoView
        setup()
    }
    
    open func setup() {
        eventsManger.listenTo(eventName: "play") { [weak self] in
            guard self != nil else { return }
            self!.delegate?.videoPlaying(self!.getCurrentTime())
        }
        eventsManger.listenTo(eventName: "pause", action: { [weak self] in
            guard self != nil else { return }
            self!.delegate?.videoPaused(self!.getCurrentTime(), userInitiated: true, isSeeking: false)
        })
        eventsManger.listenTo(eventName: "seek") { [weak self] in
            guard self != nil else { return }
            if self!.isPlaying() {
                self!.delegate?.videoPlaying(self!.getCurrentTime())
            } else {
                self!.delegate?.videoPaused(self!.getCurrentTime(), userInitiated: false, isSeeking: false)
            }
        }
        eventsManger.listenTo(eventName: "finish", action: { [weak self] in
            guard self != nil else { return }
            self!.delegate?.videoPaused(self!.getCurrentTime(), userInitiated: false, isSeeking: false)
        })
    }
    
    open func startVideo(_ url: URL) {
 
    }
    
    open func getPlayerView() -> UIView? {
        return view ?? mdstrm.view
    }
    
    open func getVideoResolution() -> CGSize {
        let resolution = mdstrm.getResolution()
        let components = resolution.split(separator: "x")
        if components.count == 2, let width = Double(components.first!), let height = Double(components.last!) {
            return CGSize(width: width, height: height )
        } else {
            return CGSize.zero
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
