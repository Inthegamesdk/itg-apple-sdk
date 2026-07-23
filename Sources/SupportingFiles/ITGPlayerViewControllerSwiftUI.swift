//
//  Inthegametv
//

import SwiftUI
import ItgPlayerViewController
#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif
import AVKit

@available(iOS 13.0, tvOS 13.0, *)
public struct ITGPlayerViewControllerSwiftUI: UIViewControllerRepresentable {

    public class Coordinator {
        
        var channelSlug: String
        var virtualChannels: [String]?
        var accountId: String
        var environment: ITGEnvironment
        var foreignId: String?
        var vars: [String: any Hashable]?
        var adsMetadata: [AdMetadata]?
        let showLogs: Bool
        let playerAdapter: ITGPlayerAdapter
        var itgPlayerViewController: ITGPlayerViewController? = nil
        
        public init(channelSlug: String, virtualChannels: [String]? = nil, accountId: String, environment: ITGEnvironment, foreignId: String? = nil, vars: [String : any Hashable]? = nil, adsMetadata: [AdMetadata]? = nil, showLogs: Bool, playerAdapter: ITGPlayerAdapter) {
            self.channelSlug = channelSlug
            self.virtualChannels = virtualChannels
            self.accountId = accountId
            self.environment = environment
            self.foreignId = foreignId
            self.vars = vars
            self.adsMetadata = adsMetadata
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
    var adsMetadata: [AdMetadata]?
    var showLogs: Bool = false
    var playerAdapter: ITGPlayerAdapter
    var onCreated: ((ITGPlayerViewController) -> Void)?
    
    public init(channelSlug: String,
                virtualChannels: [String]? = nil,
                accountId: String,
                environment: ITGEnvironment,
                foreignId: String? = nil,
                vars: [String : any Hashable]? = nil,
                adsMetadata: [AdMetadata]? = nil,
                showLogs: Bool = false,
                playerAdapter: ITGPlayerAdapter,
                onCreated: ((ITGPlayerViewController) -> Void)? = nil) {
        self.channelSlug = channelSlug
        self.virtualChannels = virtualChannels
        self.accountId = accountId
        self.environment = environment
        self.foreignId = foreignId
        self.vars = vars
        self.adsMetadata = adsMetadata
        self.showLogs = showLogs
        self.playerAdapter = playerAdapter
        self.onCreated = onCreated
    }
    
    public func makeUIViewController(context: Context) -> ITGPlayerViewController {
        context.coordinator.itgPlayerViewController = ITGPlayerViewController(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, foreignId: foreignId, vars: vars, adsMetadata: adsMetadata, playerAdapter: playerAdapter, shouldResetOverlayUser: false, showLogs: showLogs)
        onCreated?(context.coordinator.itgPlayerViewController!)
        return context.coordinator.itgPlayerViewController!
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, foreignId: foreignId, vars: vars, adsMetadata: adsMetadata, showLogs: showLogs, playerAdapter: playerAdapter)
    }
    
    public func updateUIViewController(_ uiViewController: ITGPlayerViewController, context: Context) {
        if context.coordinator.channelSlug != channelSlug
            || context.coordinator.virtualChannels != virtualChannels
            || context.coordinator.accountId != accountId
            || context.coordinator.environment != environment
            || context.coordinator.foreignId != foreignId
            || context.coordinator.adsMetadata != adsMetadata
            || context.coordinator.playerAdapter !== playerAdapter
            || context.coordinator.showLogs != showLogs
            || context.coordinator.vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) != vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) {
            context.coordinator.itgPlayerViewController = ITGPlayerViewController(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, foreignId: foreignId, vars: vars, adsMetadata: adsMetadata, playerAdapter: playerAdapter, shouldResetOverlayUser: false, showLogs: showLogs)
            context.coordinator.channelSlug = channelSlug
            context.coordinator.virtualChannels = virtualChannels
            context.coordinator.accountId = accountId
            context.coordinator.environment = environment
            context.coordinator.foreignId = foreignId
            context.coordinator.adsMetadata = adsMetadata
            context.coordinator.vars = vars
        }
    }
    
}
