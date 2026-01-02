//
//  ITGOverlayViewSwiftUI.swift
//  test
//
//  Created by ilya khymych on 26.11.2025.
//

import SwiftUI
#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif
import AVKit

@available(iOS 13.0, tvOS 13.0, *)
public struct ITGOverlayViewSwiftUI<Content: View>: UIViewRepresentable {
    
    public class Coordinator: ITGOverlayDelegate {
        
        let overlayView: ITGOverlayView = ITGOverlayView()
        var uikitVideoView: UIView
        var channelSlug: String
        var virtualChannels: [String]?
        var accountId: String
        var environment: ITGEnvironment
        var foreignId: String?
        var vars: [String : any Hashable]?
        var enableLogs: Bool
        var playerIsPlaying: Bool
        let onOverlayDidLoadChannelInfo: ((_ videoUrl: String?) -> Void)?
        let onOverlayRequestedVideoTime: () -> TimeInterval
        let onOverlayRequestedPause: () -> Void
        let onOverlayRequestedPlay: () -> Void
        let onOverlayRequestedFocus: () -> Void
        let onOnOverlayReleasedFocus: () -> Void
        let onOverlayReceivedDeeplink: ((String) -> Void)?
        let onOverlayRequestedVideoSeek: (TimeInterval) -> Void
        let onOverlayRequestedVideoResolution: (() -> CGSize)?
        let onOverlayDidProcessAnalyticEvent: ((AnalyticsInfo, AnalyticsEventType) -> Void)?
        let onUserState: ((User) -> Void)?
        let onOverlayDidPresentContent: ((ITGContent) -> Void)?
        let onOverlayDidEndPresentingContent: ((ITGContent) -> Void)?
        let onOverlayRequestedVideoLength: (() -> TimeInterval)?
        let onOverlayRequestedVideoGravity: ((AVLayerVideoGravity) -> Void)?
        let onOverlayRequestedResetVideoGravity: (() -> Void)?
        let onOverlayRequestedVideoSoundLevel: (Float) -> Void
        let onOverlayRequestedResetVideoSoundLevel: () -> Void
        let onOverlayWillChangeVideoRect: ((CGRect, TimeInterval) -> Void)?
        let onOverlayWillResetVideoRect: ((TimeInterval) -> Void)?
        private var observation: NSKeyValueObservation?
        
        public init(channelSlug: String,
                    uikitVideoView: UIView,
                    virtualChannels: [String]? = nil,
                    accountId: String,
                    environment: ITGEnvironment,
                    foreignId: String? = nil,
                    vars: [String : any Hashable]? = nil,
                    enableLogs: Bool,
                    playerIsPlaying: Bool,
                    onOverlayDidLoadChannelInfo: ((_: String?) -> Void)? = nil,
                    onOverlayRequestedVideoTime: @escaping () -> TimeInterval,
                    onOverlayRequestedPause: @escaping () -> Void,
                    onOverlayRequestedPlay: @escaping () -> Void,
                    onOverlayRequestedFocus: @escaping () -> Void,
                    onOnOverlayReleasedFocus: @escaping () -> Void,
                    onOverlayReceivedDeeplink: ((String) -> Void)? = nil,
                    onOverlayRequestedVideoSeek: @escaping (TimeInterval) -> Void,
                    onOverlayRequestedVideoResolution: (() -> CGSize)? = nil,
                    onOverlayDidProcessAnalyticEvent: ((AnalyticsInfo, AnalyticsEventType) -> Void)? = nil,
                    onUserState: ((User) -> Void)? = nil,
                    onOverlayDidPresentContent: ((ITGContent) -> Void)? = nil,
                    onOverlayDidEndPresentingContent: ((ITGContent) -> Void)? = nil,
                    onOverlayRequestedVideoLength: (() -> TimeInterval)? = nil,
                    onOverlayRequestedVideoGravity: ((AVLayerVideoGravity) -> Void)? = nil,
                    onOverlayRequestedResetVideoGravity: (() -> Void)? = nil,
                    onOverlayRequestedVideoSoundLevel: @escaping (Float) -> Void,
                    onOverlayRequestedResetVideoSoundLevel: @escaping () -> Void,
                    onOverlayWillChangeVideoRect: ((CGRect, TimeInterval) -> Void)? = nil,
                    onOverlayWillResetVideoRect: ((TimeInterval) -> Void)? = nil) {
            self.uikitVideoView = uikitVideoView
            self.channelSlug = channelSlug
            self.virtualChannels = virtualChannels
            self.accountId = accountId
            self.environment = environment
            self.foreignId = foreignId
            self.vars = vars
            self.enableLogs = enableLogs
            self.playerIsPlaying = playerIsPlaying
            self.onOverlayDidLoadChannelInfo = onOverlayDidLoadChannelInfo
            self.onOverlayRequestedVideoTime = onOverlayRequestedVideoTime
            self.onOverlayRequestedPause = onOverlayRequestedPause
            self.onOverlayRequestedPlay = onOverlayRequestedPlay
            self.onOverlayRequestedFocus = onOverlayRequestedFocus
            self.onOnOverlayReleasedFocus = onOnOverlayReleasedFocus
            self.onOverlayReceivedDeeplink = onOverlayReceivedDeeplink
            self.onOverlayRequestedVideoSeek = onOverlayRequestedVideoSeek
            self.onOverlayRequestedVideoResolution = onOverlayRequestedVideoResolution
            self.onOverlayDidProcessAnalyticEvent = onOverlayDidProcessAnalyticEvent
            self.onUserState = onUserState
            self.onOverlayDidPresentContent = onOverlayDidPresentContent
            self.onOverlayDidEndPresentingContent = onOverlayDidEndPresentingContent
            self.onOverlayRequestedVideoLength = onOverlayRequestedVideoLength
            self.onOverlayRequestedVideoGravity = onOverlayRequestedVideoGravity
            self.onOverlayRequestedResetVideoGravity = onOverlayRequestedResetVideoGravity
            self.onOverlayRequestedVideoSoundLevel = onOverlayRequestedVideoSoundLevel
            self.onOverlayRequestedResetVideoSoundLevel = onOverlayRequestedResetVideoSoundLevel
            self.onOverlayWillChangeVideoRect = onOverlayWillChangeVideoRect
            self.onOverlayWillResetVideoRect = onOverlayWillResetVideoRect
        }
        
        public func overlayDidLoadChannelInfo(_ videoUrl: String?) {
            onOverlayDidLoadChannelInfo?(videoUrl)
        }
        
        public func overlayRequestedVideoTime() {
            if playerIsPlaying {
                overlayView.videoPlaying(time: onOverlayRequestedVideoTime())
            } else {
                overlayView.videoPaused(time: onOverlayRequestedVideoTime())
            }
        }
        
        public func overlayRequestedPause() {
            onOverlayRequestedPause()
        }
        
        public func overlayRequestedPlay() {
            onOverlayRequestedPlay()
        }
        
        public func overlayRequestedFocus() {
            onOverlayRequestedFocus()
        }
        
        public func overlayReleasedFocus() {
            onOnOverlayReleasedFocus()
        }
        
        public func overlayReceivedDeeplink(_ link: String) {
            onOverlayReceivedDeeplink?(link)
        }
        
        public func overlayRequestedVideoSeek(time: TimeInterval) {
            onOverlayRequestedVideoSeek(time)
        }
        
        public func overlayRequestedVideoResolution() -> CGSize {
            return onOverlayRequestedVideoResolution?() ?? CGSize.zero
        }
        
        public func overlayDidProcessAnalyticEvent(info: AnalyticsInfo, type: AnalyticsEventType) {
            onOverlayDidProcessAnalyticEvent?(info, type)
        }
        
        public func userState(_ user: User) {
            onUserState?(user)
        }
        
        public func overlayDidPresentContent(_ content: ITGContent) {
            onOverlayDidPresentContent?(content)
        }
        
        public func overlayDidEndPresentingContent(_ content: ITGContent) {
            onOverlayDidEndPresentingContent?(content)
        }
        
        public func overlayRequestedVideoLength() -> TimeInterval {
            return onOverlayRequestedVideoLength?() ?? 0
        }
        
        public func overlayRequestedVideoGravity(_ videoGravity: AVLayerVideoGravity) {
            if onOverlayRequestedVideoGravity != nil {
                onOverlayRequestedVideoGravity?(videoGravity)
            } else {
                requestedVideoGravity(videoGravity, preventChange: true)
            }
        }
        
        public func overlayRequestedResetVideoGravity() {
            if onOverlayRequestedResetVideoGravity != nil {
                onOverlayRequestedResetVideoGravity?()
            } else {
                resetVideoGravity()
            }
        }
        
        public func overlayRequestedVideoSoundLevel(_ soundLevel: Float) {
            onOverlayRequestedVideoSoundLevel(soundLevel)
        }
        
        public func overlayRequestedResetVideoSoundLevel() {
            onOverlayRequestedResetVideoSoundLevel()
        }
        
        public func overlayWillChangeVideoRect(_ rect: CGRect, animationDuration: TimeInterval) {
            onOverlayWillChangeVideoRect?(rect, animationDuration)
        }
        
        public func overlayWillResetVideoRect(_ animationDuration: TimeInterval) {
            onOverlayWillResetVideoRect?(animationDuration)
        }
        
        private func resetVideoGravity() {
            observation?.invalidate()
            observation = nil
            requestedVideoGravity(.resizeAspect, preventChange: false)
        }
        
        private func requestedVideoGravity(_ videoGravity: AVLayerVideoGravity, preventChange: Bool) -> Void {
            if let playerLayer = Set(uikitVideoView.deepSubviews().compactMap({ $0.layer.deepSublayers() }).flatMap({ $0 })).first(where: { $0 is AVPlayerLayer && $0.isHidden == false && $0.frame != CGRect.zero }) as? AVPlayerLayer {
                playerLayer.videoGravity = videoGravity
                if preventChange {
                    if observation == nil {
                        observation = playerLayer.observe(\.videoGravity, options: [.new, .old]) { layer, change in
                            if change.newValue != videoGravity {
                                self.requestedVideoGravity(videoGravity, preventChange: true)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    var channelSlug: String
    var virtualChannels: [String]?
    var accountId: String
    var environment: ITGEnvironment
    var foreignId: String? = nil
    var videoView: Content
    var vars: [String : any Hashable]? = nil
    var enableLogs: Bool = false
    var blockAll: Bool
    var playerIsPlaying: Bool
    var onOverlayDidLoadChannelInfo: ((_ videoUrl: String?) -> Void)?
    var onOverlayRequestedVideoTime: () -> TimeInterval
    var onOverlayRequestedPause: () -> Void
    var onOverlayRequestedPlay: () -> Void
    var onOverlayRequestedFocus: () -> Void
    var onOnOverlayReleasedFocus: () -> Void
    var onOverlayReceivedDeeplink: ((String) -> Void)?
    var onOverlayRequestedVideoSeek: (TimeInterval) -> Void
    var onOverlayRequestedVideoResolution: (() -> CGSize)?
    var onOverlayDidProcessAnalyticEvent: ((AnalyticsInfo, AnalyticsEventType) -> Void)?
    var onUserState: ((User) -> Void)?
    var onOverlayDidPresentContent: ((ITGContent) -> Void)?
    var onOverlayDidEndPresentingContent: ((ITGContent) -> Void)?
    var onOverlayRequestedVideoLength: (() -> TimeInterval)?
    var onOverlayRequestedVideoGravity: ((AVLayerVideoGravity) -> Void)?
    var onOverlayRequestedResetVideoGravity: (() -> Void)?
    var onOverlayRequestedVideoSoundLevel: (Float) -> Void
    var onOverlayRequestedResetVideoSoundLevel: () -> Void
    var onOverlayWillChangeVideoRect: ((CGRect, TimeInterval) -> Void)?
    var onOverlayWillResetVideoRect: ((TimeInterval) -> Void)?
    
    public init(channelSlug: String,
                virtualChannels: [String]? = nil,
                accountId: String,
                environment: ITGEnvironment,
                foreignId: String? = nil,
                videoView: any View,
                vars: [String : any Hashable]? = nil,
                enableLogs: Bool = false,
                blockAll: Bool,
                playerIsPlaying: Bool,
                onOverlayDidLoadChannelInfo: ((_: String?) -> Void)? = nil,
                onOverlayRequestedVideoTime: @escaping () -> TimeInterval,
                onOverlayRequestedPause: @escaping () -> Void,
                onOverlayRequestedPlay: @escaping () -> Void,
                onOverlayRequestedFocus: @escaping () -> Void,
                onOnOverlayReleasedFocus: @escaping () -> Void,
                onOverlayReceivedDeeplink: ((String) -> Void)? = nil,
                onOverlayRequestedVideoSeek: @escaping (TimeInterval) -> Void,
                onOverlayRequestedVideoResolution: (() -> CGSize)? = nil,
                onOverlayDidProcessAnalyticEvent: ((AnalyticsInfo, AnalyticsEventType) -> Void)? = nil,
                onUserState: ((User) -> Void)? = nil,
                onOverlayDidPresentContent: ((ITGContent) -> Void)? = nil,
                onOverlayDidEndPresentingContent: ((ITGContent) -> Void)? = nil,
                onOverlayRequestedVideoLength: (() -> TimeInterval)? = nil,
                onOverlayRequestedVideoGravity: ((AVLayerVideoGravity) -> Void)? = nil,
                onOverlayRequestedResetVideoGravity: (() -> Void)? = nil,
                onOverlayRequestedVideoSoundLevel: @escaping (Float) -> Void,
                onOverlayRequestedResetVideoSoundLevel: @escaping () -> Void,
                onOverlayWillChangeVideoRect: ((CGRect, TimeInterval) -> Void)? = nil,
                onOverlayWillResetVideoRect: ((TimeInterval) -> Void)? = nil,
                onOverlayCreated: ((ITGOverlayViewSwiftUI) -> Void)? = nil,
                uikitVideoView: UIView? = nil) {
        self.channelSlug = channelSlug
        self.virtualChannels = virtualChannels
        self.accountId = accountId
        self.environment = environment
        self.foreignId = foreignId
        self.videoView = videoView as! Content
        self.vars = vars
        self.enableLogs = enableLogs
        self.blockAll = blockAll
        self.playerIsPlaying = playerIsPlaying
        self.onOverlayDidLoadChannelInfo = onOverlayDidLoadChannelInfo
        self.onOverlayRequestedVideoTime = onOverlayRequestedVideoTime
        self.onOverlayRequestedPause = onOverlayRequestedPause
        self.onOverlayRequestedPlay = onOverlayRequestedPlay
        self.onOverlayRequestedFocus = onOverlayRequestedFocus
        self.onOnOverlayReleasedFocus = onOnOverlayReleasedFocus
        self.onOverlayReceivedDeeplink = onOverlayReceivedDeeplink
        self.onOverlayRequestedVideoSeek = onOverlayRequestedVideoSeek
        self.onOverlayRequestedVideoResolution = onOverlayRequestedVideoResolution
        self.onOverlayDidProcessAnalyticEvent = onOverlayDidProcessAnalyticEvent
        self.onUserState = onUserState
        self.onOverlayDidPresentContent = onOverlayDidPresentContent
        self.onOverlayDidEndPresentingContent = onOverlayDidEndPresentingContent
        self.onOverlayRequestedVideoLength = onOverlayRequestedVideoLength
        self.onOverlayRequestedVideoGravity = onOverlayRequestedVideoGravity
        self.onOverlayRequestedResetVideoGravity = onOverlayRequestedResetVideoGravity
        self.onOverlayRequestedVideoSoundLevel = onOverlayRequestedVideoSoundLevel
        self.onOverlayRequestedResetVideoSoundLevel = onOverlayRequestedResetVideoSoundLevel
        self.onOverlayWillChangeVideoRect = onOverlayWillChangeVideoRect
        self.onOverlayWillResetVideoRect = onOverlayWillResetVideoRect
    }

    public func makeUIView(context: Context) -> ITGOverlayView {
        context.coordinator.uikitVideoView.backgroundColor = .clear
        context.coordinator.overlayView.load(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, delegate: context.coordinator, foreignId: foreignId, videoView: context.coordinator.uikitVideoView, vars: vars, enableLogs: enableLogs)
        return context.coordinator.overlayView
    }

    public func updateUIView(_ uiView: ITGOverlayView, context: Context) {
        if context.coordinator.channelSlug != channelSlug
            || context.coordinator.virtualChannels != virtualChannels
            || context.coordinator.accountId != accountId
            || context.coordinator.environment != environment
            || context.coordinator.foreignId != foreignId
            || context.coordinator.vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) != vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) {
            context.coordinator.uikitVideoView = UIHostingController(rootView: self.videoView).view
            context.coordinator.overlayView.load(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, delegate: context.coordinator, foreignId: foreignId, videoView: context.coordinator.uikitVideoView, vars: vars, enableLogs: enableLogs)
            context.coordinator.channelSlug = channelSlug
            context.coordinator.virtualChannels = virtualChannels
            context.coordinator.accountId = accountId
            context.coordinator.environment = environment
            context.coordinator.foreignId = foreignId
            context.coordinator.vars = vars
        }
        context.coordinator.overlayView.blockAll(blockAll, includingPauseAds: true)
        context.coordinator.playerIsPlaying = playerIsPlaying
        if playerIsPlaying {
            context.coordinator.overlayView.videoPlaying(time: onOverlayRequestedVideoTime())
        } else {
            context.coordinator.overlayView.videoPaused(time: onOverlayRequestedVideoTime())
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(channelSlug: channelSlug,
                           uikitVideoView: UIHostingController(rootView: self.videoView).view,
                           virtualChannels: virtualChannels,
                           accountId: accountId,
                           environment: environment,
                           foreignId: foreignId,
                           vars: vars,
                           enableLogs: enableLogs,
                           playerIsPlaying: playerIsPlaying,
                           onOverlayDidLoadChannelInfo: onOverlayDidLoadChannelInfo,
                           onOverlayRequestedVideoTime: onOverlayRequestedVideoTime,
                           onOverlayRequestedPause: onOverlayRequestedPause,
                           onOverlayRequestedPlay: onOverlayRequestedPlay,
                           onOverlayRequestedFocus: onOverlayRequestedFocus,
                           onOnOverlayReleasedFocus: onOnOverlayReleasedFocus,
                           onOverlayReceivedDeeplink: onOverlayReceivedDeeplink,
                           onOverlayRequestedVideoSeek: onOverlayRequestedVideoSeek,
                           onOverlayRequestedVideoResolution: onOverlayRequestedVideoResolution,
                           onOverlayDidProcessAnalyticEvent: onOverlayDidProcessAnalyticEvent,
                           onUserState: onUserState,
                           onOverlayDidPresentContent: onOverlayDidPresentContent,
                           onOverlayDidEndPresentingContent: onOverlayDidEndPresentingContent,
                           onOverlayRequestedVideoLength: onOverlayRequestedVideoLength,
                           onOverlayRequestedVideoGravity: onOverlayRequestedVideoGravity,
                           onOverlayRequestedResetVideoGravity: onOverlayRequestedResetVideoGravity,
                           onOverlayRequestedVideoSoundLevel: onOverlayRequestedVideoSoundLevel,
                           onOverlayRequestedResetVideoSoundLevel: onOverlayRequestedPlay,
                           onOverlayWillChangeVideoRect: onOverlayWillChangeVideoRect,
                           onOverlayWillResetVideoRect: onOverlayWillResetVideoRect)
    }
    
}
