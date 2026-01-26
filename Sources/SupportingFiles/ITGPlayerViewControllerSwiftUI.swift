//
//  Inthegametv
//

import SwiftUI
#if canImport(ITGPlayerViewController)
import ITGPlayerViewController
#endif
#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif
import AVKit

public struct ITGPlayerViewControllerSwiftUI: UIViewControllerRepresentable {

    public class Coordinator: Equatable {
        
        var channelSlug: String
        var virtualChannels: [String]?
        var accountId: String
        var environment: ITGEnvironment
        var foreignId: String?
        var vars: [String: any Hashable]?
        let showLogs: Bool
        let playerAdapter: ITGPlayerAdapter
        var itgPlayerViewController: ITGPlayerViewController? = nil
        
        public static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
            return lhs.channelSlug == rhs.channelSlug
            && lhs.virtualChannels == rhs.virtualChannels
            && lhs.accountId == rhs.accountId
            && lhs.environment == rhs.environment
            && lhs.foreignId == rhs.foreignId
            && lhs.vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) == rhs.vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) })
            && lhs.showLogs == rhs.showLogs
            && lhs.playerAdapter === rhs.playerAdapter
        }
        
        public init(channelSlug: String, virtualChannels: [String]? = nil, accountId: String, environment: ITGEnvironment, foreignId: String? = nil, vars: [String : any Hashable]? = nil, showLogs: Bool, playerAdapter: ITGPlayerAdapter) {
            self.channelSlug = channelSlug
            self.virtualChannels = virtualChannels
            self.accountId = accountId
            self.environment = environment
            self.foreignId = foreignId
            self.vars = vars
            self.showLogs = showLogs
            self.playerAdapter = playerAdapter
        }
        
    }
    
    var channelSlug: String
    var virtualChannels: [String]?
    var accountId: String
    var environment: ITGEnvironment
    var foreignId: String? = nil
    var vars: [String: any Hashable]? = nil
    var showLogs: Bool = false
    var playerAdapter: ITGPlayerAdapter
    var onCreated: ((ITGPlayerViewController) -> Void)?
    
    public init(channelSlug: String,
                virtualChannels: [String]? = nil,
                accountId: String,
                environment: ITGEnvironment,
                foreignId: String? = nil,
                vars: [String : any Hashable]? = nil,
                showLogs: Bool = false,
                playerAdapter: ITGPlayerAdapter,
                onCreated: ((ITGPlayerViewController) -> Void)? = nil) {
        self.channelSlug = channelSlug
        self.virtualChannels = virtualChannels
        self.accountId = accountId
        self.environment = environment
        self.foreignId = foreignId
        self.vars = vars
        self.showLogs = showLogs
        self.playerAdapter = playerAdapter
        self.onCreated = onCreated
    }
    
    public func makeUIViewController(context: Context) -> ITGPlayerViewController {
        context.coordinator.itgPlayerViewController = ITGPlayerViewController(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, foreignId: foreignId, vars: vars, playerAdapter: playerAdapter, shouldResetOverlayUser: false, showLogs: showLogs)
        context.coordinator.itgPlayerViewController?.shouldPlayChannelVideo = false
        onCreated?(context.coordinator.itgPlayerViewController!)
        return context.coordinator.itgPlayerViewController!
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, foreignId: foreignId, vars: vars, showLogs: showLogs, playerAdapter: playerAdapter)
    }
    
    public func updateUIViewController(_ uiViewController: ITGPlayerViewController, context: Context) {
        if context.coordinator.channelSlug != channelSlug
            || context.coordinator.virtualChannels != virtualChannels
            || context.coordinator.accountId != accountId
            || context.coordinator.environment != environment
            || context.coordinator.foreignId != foreignId
            || context.coordinator.vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) != vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) {
            context.coordinator.itgPlayerViewController = ITGPlayerViewController(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, foreignId: foreignId, vars: vars, playerAdapter: playerAdapter, shouldResetOverlayUser: false, showLogs: showLogs)
            context.coordinator.channelSlug = channelSlug
            context.coordinator.virtualChannels = virtualChannels
            context.coordinator.accountId = accountId
            context.coordinator.environment = environment
            context.coordinator.foreignId = foreignId
            context.coordinator.vars = vars
        }
    }
    
}
