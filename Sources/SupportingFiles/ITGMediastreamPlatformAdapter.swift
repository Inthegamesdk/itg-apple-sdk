//
//  Inthegametv
//

import AVKit

#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif
import ItgPlayerViewController

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
    func getDuration() -> Int64
     
 }

public protocol ITGMediastreamPlatformEventManager {
    
    func listenTo(eventName: String, action: @escaping () -> ())
    
}


open class ITGMediastreamPlatformAdapter: ITGPlayerAdapter {
    
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
    
    open func getVideoGravity() -> AVLayerVideoGravity? {
        return mdstrm.playerViewController?.videoGravity ?? mdstrm.playerLayer?.videoGravity 
    }
    open func setSoundLevel(_ soundLevel: Float) {
        mdstrm.volume = Int(soundLevel*100)
    }
    
    open func getSoundLevel() -> Float {
        return Float(mdstrm.volume)/100
    }
    
}
