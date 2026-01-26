//
//  Inthegametv
//

import SwiftUI
#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif
import AVKit

public struct ITGOverlayViewSwiftUI<Content: View>: UIViewRepresentable {
    
    public class Coordinator: ITGOverlayDelegate, Equatable {
        
        let overlayView: ITGOverlayView = ITGOverlayView()
        var channelSlug: String
        var virtualChannels: [String]?
        var accountId: String
        var environment: ITGEnvironment
        var foreignId: String?
        var vars: [String : any Hashable]?
        let showLogs: Bool
        let onItgDidLoadChannelInfo: ((ChannelMeta)->Void)?
        let onItgRequestedVideoStateChange: (ITGPlayerState, TimeInterval?)->Void
        let onItgRequestedFocusUpdate: (Bool)->Void
        let onItgRequestedVideoRectChange: (CGRect?, TimeInterval) -> Void
        let onItgReceivedDeeplink: ((String)->Void)?
        let onItgDidProcessAnalyticEvent: ((AnalyticsInfo, AnalyticsEventType)->Void)?
        let onItgDidUpdateUserState: ((User)->Void)?
        let onItgRequestedVideoSoundLevel: (Float?)->Void
        let onItgRequestedVideoGravity: (AVLayerVideoGravity?)->Void
        
        public static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
            return lhs.channelSlug == rhs.channelSlug
            && lhs.virtualChannels == rhs.virtualChannels
            && lhs.accountId == rhs.accountId
            && lhs.environment == rhs.environment
            && lhs.foreignId == rhs.foreignId
            && lhs.vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) == rhs.vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) })
            && lhs.showLogs == rhs.showLogs
        }
        
        public init(channelSlug: String,
                    virtualChannels: [String]?,
                    accountId: String,
                    environment: ITGEnvironment,
                    foreignId: String?,
                    vars: [String : any Hashable]?,
                    showLogs: Bool,
                    onItgDidLoadChannelInfo: ((ChannelMeta) -> Void)?,
                    onItgRequestedVideoStateChange: @escaping (ITGPlayerState, TimeInterval?) -> Void,
                    onItgRequestedFocusUpdate: @escaping (Bool) -> Void,
                    onItgRequestedVideoRectChange: @escaping (CGRect?, TimeInterval) -> Void,
                    onItgReceivedDeeplink: ((String) -> Void)?,
                    onItgDidProcessAnalyticEvent: ((AnalyticsInfo, AnalyticsEventType) -> Void)?,
                    onItgDidUpdateUserState: ((User) -> Void)?,
                    onItgRequestedVideoSoundLevel: @escaping (Float?) -> Void,
                    onItgRequestedVideoGravity: @escaping (AVLayerVideoGravity?)->Void) {
            self.channelSlug = channelSlug
            self.virtualChannels = virtualChannels
            self.accountId = accountId
            self.environment = environment
            self.foreignId = foreignId
            self.vars = vars
            self.showLogs = showLogs
            self.onItgDidLoadChannelInfo = onItgDidLoadChannelInfo
            self.onItgRequestedVideoStateChange = onItgRequestedVideoStateChange
            self.onItgRequestedFocusUpdate = onItgRequestedFocusUpdate
            self.onItgRequestedVideoRectChange = onItgRequestedVideoRectChange
            self.onItgReceivedDeeplink = onItgReceivedDeeplink
            self.onItgDidProcessAnalyticEvent = onItgDidProcessAnalyticEvent
            self.onItgDidUpdateUserState = onItgDidUpdateUserState
            self.onItgRequestedVideoSoundLevel = onItgRequestedVideoSoundLevel
            self.onItgRequestedVideoGravity = onItgRequestedVideoGravity
        }
        
        public func itgDidLoadChannelInfo(_ channelMeta: ChannelMeta) {
            onItgDidLoadChannelInfo?(channelMeta)
        }
        
        public func itgRequestedVideoStateChange(_ state: ITGPlayerState, timeStamp: TimeInterval?) {
            onItgRequestedVideoStateChange(state, timeStamp)
        }
        
        public func itgRequestedFocusUpdate(_ focusRequired: Bool) {
            onItgRequestedFocusUpdate(focusRequired)
        }
        
        public func itgRequestedVideoRectChange(_ rect: CGRect?, animationTime: TimeInterval) {
            onItgRequestedVideoRectChange(rect, animationTime)
        }
        
        public func itgReceivedDeeplink(_ link: String) {
            onItgReceivedDeeplink?(link)
        }
        
        public func itgDidProcessAnalyticEvent(info: AnalyticsInfo, type: AnalyticsEventType) {
            onItgDidProcessAnalyticEvent?(info, type)
        }
        
        public func itgDidUpdateUserState(_ user: User) {
            onItgDidUpdateUserState?(user)
        }
        
        public func itgRequestedVideoSoundLevel(_ soundLevel: Float?) {
            onItgRequestedVideoSoundLevel(soundLevel)
        }
        
        public func itgRequestedVideoGravity(_ videoGravity: AVLayerVideoGravity?) {
            onItgRequestedVideoGravity(videoGravity)
        }
        
    }
    
    var channelSlug: String
    var virtualChannels: [String]?
    var accountId: String
    var environment: ITGEnvironment
    var foreignId: String? = nil
    var vars: [String : any Hashable]? = nil
    var showLogs: Bool = false
    let onItgDidLoadChannelInfo: ((ChannelMeta)->Void)?
    let onItgRequestedVideoStateChange: (ITGPlayerState, TimeInterval?)->Void
    let onItgRequestedFocusUpdate: (Bool)->Void
    let onItgRequestedVideoRectChange: ((CGRect?, TimeInterval) -> Void)
    let onItgReceivedDeeplink: ((String)->Void)?
    let onItgDidProcessAnalyticEvent: ((AnalyticsInfo, AnalyticsEventType)->Void)?
    let onItgDidUpdateUserState: ((User)->Void)?
    let onItgRequestedVideoSoundLevel: (Float?)->Void
    let onItgRequestedVideoGravity: (AVLayerVideoGravity?)->Void
    let onItgOverlayCreated: ((ITGOverlayView) -> Void)?
    
    public init(channelSlug: String,
                virtualChannels: [String]? = nil,
                accountId: String,
                environment: ITGEnvironment,
                foreignId: String? = nil,
                vars: [String : any Hashable]? = nil,
                showLogs: Bool = false,
                onOverlayDidLoadChannelInfo: ((_: String?) -> Void)? = nil,
                onItgDidLoadChannelInfo: ((ChannelMeta) -> Void)?,
                onItgRequestedVideoStateChange: @escaping (ITGPlayerState, TimeInterval?) -> Void,
                onItgRequestedFocusUpdate: @escaping (Bool) -> Void,
                onItgRequestedVideoRectChange: @escaping (CGRect?, TimeInterval) -> Void,
                onItgReceivedDeeplink: ((String) -> Void)?,
                onItgDidProcessAnalyticEvent: ((AnalyticsInfo, AnalyticsEventType) -> Void)?,
                onItgDidUpdateUserState: ((User) -> Void)?,
                onItgRequestedVideoSoundLevel: @escaping (Float?) -> Void,
                onItgRequestedVideoGravity: @escaping (AVLayerVideoGravity?)->Void,
                onItgOverlayCreated: ((ITGOverlayView) -> Void)? = nil) {
        self.channelSlug = channelSlug
        self.virtualChannels = virtualChannels
        self.accountId = accountId
        self.environment = environment
        self.foreignId = foreignId
        self.vars = vars
        self.showLogs = showLogs
        self.onItgDidLoadChannelInfo = onItgDidLoadChannelInfo
        self.onItgRequestedVideoStateChange = onItgRequestedVideoStateChange
        self.onItgRequestedFocusUpdate = onItgRequestedFocusUpdate
        self.onItgRequestedVideoRectChange = onItgRequestedVideoRectChange
        self.onItgReceivedDeeplink = onItgReceivedDeeplink
        self.onItgDidProcessAnalyticEvent = onItgDidProcessAnalyticEvent
        self.onItgDidUpdateUserState = onItgDidUpdateUserState
        self.onItgRequestedVideoSoundLevel = onItgRequestedVideoSoundLevel
        self.onItgRequestedVideoGravity = onItgRequestedVideoGravity
        self.onItgOverlayCreated = onItgOverlayCreated
    }
    
    public func makeUIView(context: Context) -> ITGOverlayView {
        context.coordinator.overlayView.load(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, delegate: context.coordinator, foreignId: foreignId, vars: vars, showLogs: showLogs)
        onItgOverlayCreated?(context.coordinator.overlayView)
        return context.coordinator.overlayView
    }
    
    public func updateUIView(_ uiView: ITGOverlayView, context: Context) {
        if context.coordinator.channelSlug != channelSlug
            || context.coordinator.virtualChannels != virtualChannels
            || context.coordinator.accountId != accountId
            || context.coordinator.environment != environment
            || context.coordinator.foreignId != foreignId
            || context.coordinator.vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) != vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) {
            context.coordinator.overlayView.load(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, delegate: context.coordinator, foreignId: foreignId, vars: vars, showLogs: showLogs)
            context.coordinator.channelSlug = channelSlug
            context.coordinator.virtualChannels = virtualChannels
            context.coordinator.accountId = accountId
            context.coordinator.environment = environment
            context.coordinator.foreignId = foreignId
            context.coordinator.vars = vars
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(channelSlug: channelSlug,
                           virtualChannels: virtualChannels,
                           accountId: accountId,
                           environment: environment,
                           foreignId: foreignId,
                           vars: vars,
                           showLogs: showLogs,
                           onItgDidLoadChannelInfo: onItgDidLoadChannelInfo,
                           onItgRequestedVideoStateChange: onItgRequestedVideoStateChange,
                           onItgRequestedFocusUpdate: onItgRequestedFocusUpdate,
                           onItgRequestedVideoRectChange: onItgRequestedVideoRectChange,
                           onItgReceivedDeeplink: onItgReceivedDeeplink,
                           onItgDidProcessAnalyticEvent: onItgDidProcessAnalyticEvent,
                           onItgDidUpdateUserState: onItgDidUpdateUserState,
                           onItgRequestedVideoSoundLevel: onItgRequestedVideoSoundLevel,
                           onItgRequestedVideoGravity: onItgRequestedVideoGravity)
    }
    
}
