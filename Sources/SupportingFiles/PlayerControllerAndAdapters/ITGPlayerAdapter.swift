//
//  ITGPlayerAdapter.swift
//  Inthegametv
//
//  Created by Daedalus on 28.07.2023.
//

import UIKit
import AVKit

public protocol ITGPlayerAdapterDelegate: AnyObject {
    
    func videoPlaying(_ time: TimeInterval)
    func videoPaused(_ time: TimeInterval)
    func videoControllsVisibilityChanged(_ isVisible: Bool)
    func menuButtonAction()
    
}

public protocol ITGPlayerAdapter: AnyObject {
    
    var delegate: ITGPlayerAdapterDelegate? { get set }
    func setup()
    func startVideo(_ url: URL)
    func getPlayerView() -> UIView?
    func getVideoResolution() -> CGSize
    func isPlaying() -> Bool
    func play()
    func pause()
    func seek(_ time: TimeInterval)
    func getCurrentTime() -> TimeInterval
    func getVideoLength() -> TimeInterval
    func setVideoGravity(_ videoGravity: AVLayerVideoGravity)
    func setSoundLevel(_ soundLevel: Float)
    func getSoundLevel() -> Float
    
}
