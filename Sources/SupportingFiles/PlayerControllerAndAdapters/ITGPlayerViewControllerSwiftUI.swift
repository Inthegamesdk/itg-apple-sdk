//
//  ITGPlayerViewControllerSwiftUI.swift
//  test
//
//  Created by ilya khymych on 27.11.2025.
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
    
    public class Coordinator {
        
        var channelSlug: String
        var virtualChannels: [String]?
        var accountId: String
        var environment: ITGEnvironment
        var foreignId: String?
        var vars: [String: any Hashable]?
        let enableLogs: Bool
        let playerAdapter: ITGPlayerAdapter
        var itgPlayerViewController: ITGPlayerViewController? = nil
        
        public init(channelSlug: String, virtualChannels: [String]? = nil, accountId: String, environment: ITGEnvironment, foreignId: String? = nil, vars: [String : any Hashable]? = nil, enableLogs: Bool, playerAdapter: ITGPlayerAdapter) {
            self.channelSlug = channelSlug
            self.virtualChannels = virtualChannels
            self.accountId = accountId
            self.environment = environment
            self.foreignId = foreignId
            self.vars = vars
            self.enableLogs = enableLogs
            self.playerAdapter = playerAdapter
        }
        
    }
    
    let channelSlug: String
    let virtualChannels: [String]?
    let accountId: String
    let environment: ITGEnvironment
    let foreignId: String?
    let vars: [String: any Hashable]?
    let enableLogs: Bool
    let playerAdapter: ITGPlayerAdapter
    let blockAll: Bool
    let shouldPlayChannelVideo: Bool
    let closeButtonVisibilityMode: ITGPlayerViewController.CloseButtonVisibilityMode
    
    public init(channelSlug: String,
                virtualChannels: [String]? = nil,
                accountId: String,
                environment: ITGEnvironment = ITGEnvironment.defaultEnvironment,
                foreignId: String? = nil,
                vars: [String : any Hashable]? = nil,
                enableLogs: Bool = false,
                playerAdapter: ITGPlayerAdapter,
                blockAll: Bool,
                shouldPlayChannelVideo: Bool = false,
                closeButtonVisibilityMode: ITGPlayerViewController.CloseButtonVisibilityMode = .hidden) {
        self.channelSlug = channelSlug
        self.virtualChannels = virtualChannels
        self.accountId = accountId
        self.environment = environment
        self.foreignId = foreignId
        self.vars = vars
        self.enableLogs = enableLogs
        self.playerAdapter = playerAdapter
        self.blockAll = blockAll
        self.shouldPlayChannelVideo = shouldPlayChannelVideo
        self.closeButtonVisibilityMode = closeButtonVisibilityMode
    }
    
    public func makeUIViewController(context: Context) -> ITGPlayerViewController {
        context.coordinator.itgPlayerViewController = ITGPlayerViewController(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, foreignId: foreignId, vars: vars, playerAdapter: playerAdapter, shouldResetOverlayUser: false, enableLogs: enableLogs)
        context.coordinator.itgPlayerViewController?.shouldPlayChannelVideo = shouldPlayChannelVideo
#if os(iOS)
        context.coordinator.itgPlayerViewController?.closeButtonVisibilityMode = closeButtonVisibilityMode
#endif
        context.coordinator.itgPlayerViewController?.overlayView?.blockAll(blockAll, includingPauseAds: true)
        return context.coordinator.itgPlayerViewController!
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, foreignId: foreignId, vars: vars, enableLogs: enableLogs, playerAdapter: playerAdapter)
    }
    
    public func updateUIViewController(_ uiViewController: ITGPlayerViewController, context: Context) {
        if context.coordinator.channelSlug != channelSlug
            || context.coordinator.virtualChannels != virtualChannels
            || context.coordinator.accountId != accountId
            || context.coordinator.environment != environment
            || context.coordinator.foreignId != foreignId
            || context.coordinator.vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) != vars?.map({ item in return String(item.key.hashValue) + String(item.value.hashValue) }) {
            context.coordinator.itgPlayerViewController?.reloadChannel(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, foreignId: foreignId, vars: vars, playerAdapter: playerAdapter, enableLogs: enableLogs)
            context.coordinator.channelSlug = channelSlug
            context.coordinator.virtualChannels = virtualChannels
            context.coordinator.accountId = accountId
            context.coordinator.environment = environment
            context.coordinator.foreignId = foreignId
            context.coordinator.vars = vars
        }
        context.coordinator.itgPlayerViewController?.overlayView?.blockAll(blockAll, includingPauseAds: true)
    }
    
}
