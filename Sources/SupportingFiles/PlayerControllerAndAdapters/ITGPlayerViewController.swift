//
//  PlayerViewController.swift
//  InthegameTVDemo
//
//  Created by Tiago Lira Pereira on 01/02/2021.
//

import UIKit
import AVFoundation
import AVKit
#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif

open class ITGPlayerViewController: UIViewController, ITGOverlayDelegate, ITGPlayerAdapterDelegate {
    
#if os(iOS)
    public enum CloseButtonVisibilityMode: String {
        
        case always
        case whilePlayerControlsVisible
        case hidden
        
    }
    
    open lazy var closeButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "close", in: Bundle(for: ITGOverlayView.self), compatibleWith: nil), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.tintColor = .white
        return button
    }()
#endif
    open override var preferredFocusEnvironments: [any UIFocusEnvironment] {
        return customPreferredFocusEnvironments ?? [view]
    }
#if os(iOS)
    open override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    public var closeButtonVisibilityMode: CloseButtonVisibilityMode = .whilePlayerControlsVisible
#endif
    public var overlayView: ITGOverlayView?
    public var autoBlock: ITGOverlayView.AutoBlockMode = .disabled
    public var autoBlockDisregard: Set<UIView> = []
    public var shouldPlayChannelVideo: Bool = true
    private var customPreferredFocusEnvironments: [any UIFocusEnvironment]? {
        didSet {
            if customPreferredFocusEnvironments != nil && !didSetInitialFocus {
                didSetInitialFocus = true
            }
        }
    }
    private var player: ITGPlayerAdapter?
    private var controllsVisible: Bool = false
    private var channelSlug: String
    private var virtualChannels: [String]?
    private var accountId: String
    private var environment: ITGEnvironment
    private var foreignId: String?
    private var shouldResetOverlayUser: Bool
    private var soundLevel: Float = 1
    private var vars: [String: any Hashable]? = nil
    private var enableLogs: Bool
    private var didSetInitialFocus = false
    
    public init(channelSlug: String, virtualChannels: [String]? = nil, accountId: String, environment: ITGEnvironment = ITGEnvironment.defaultEnvironment, foreignId: String? = nil, vars: [String: any Hashable]? = nil, playerAdapter: ITGPlayerAdapter, shouldResetOverlayUser: Bool = false, enableLogs: Bool = false) {
        self.channelSlug = channelSlug
        self.virtualChannels = virtualChannels
        self.accountId = accountId
        self.environment = environment
        self.foreignId = foreignId
        self.shouldResetOverlayUser = shouldResetOverlayUser
        self.player = playerAdapter
        self.vars = vars
        self.enableLogs = enableLogs
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removePlayer()
    }
    
    open override func loadView() {
        view = FocusObservableView()
#if os(tvOS)
        (view as? FocusObservableView)?.focusChangeObservationBlock = { [weak self] focusedItem in
            self?.toggleOverlayBlock(focusedItem)
        }
#endif
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
#if os(tvOS)
        configureRemoteButtonsHandlers()
#else
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        orientationDidChange()
        if closeButtonVisibilityMode == .hidden {
            closeButton.isHidden = true
        }
        view.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
#endif
        setupOverlay()
        setupPlayer()
        player?.delegate = self
#if os(iOS)
        view.bringSubviewToFront(closeButton)
#endif
    }
  
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moveFocusToPlayerView()
    }
    
#if os(iOS)
    open override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        if view.window == nil {
            orientationDidChange()
        }
    }
#endif
    
    open func reloadChannel(channelSlug: String, virtualChannels: [String]? = nil, accountId: String, environment: ITGEnvironment = ITGEnvironment.defaultEnvironment, foreignId: String? = nil, vars: [String: any Hashable]? = nil, playerAdapter: ITGPlayerAdapter, shouldResetOverlayUser: Bool = false, enableLogs: Bool = false) {
        self.channelSlug = channelSlug
        self.virtualChannels = virtualChannels
        self.accountId = accountId
        self.environment = environment
        self.foreignId = foreignId
        self.shouldResetOverlayUser = shouldResetOverlayUser
        self.player = playerAdapter
        self.vars = vars
        self.enableLogs = enableLogs
        overlayView?.load(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, delegate: self, foreignId: foreignId, videoView: player!.getPlayerView()!, vars: vars, enableLogs: enableLogs)
    }
    
    open func toggleOverlayBlock(_ focusedItem: UIView?) {
        if autoBlock == .auto, let overlayView = self.overlayView, let playerView = player?.getPlayerView() {
            overlayView.autoBlockValue = focusedItem != nil && (focusedItem?.isDescendant(of: overlayView) != true || (focusedItem?.isDescendant(of: playerView) == true && controllsVisible) && !autoBlockDisregard.contains(where: { focusedItem?.isDescendant(of: $0) == true }))
        }
    }
    
    open func setupPlayer() {
#if os(iOS)
        orientationDidChange()
#endif
    }
    
    open func startVideo(_ url: URL) {
#if os(iOS)
        if closeButtonVisibilityMode != .always {
            closeButton.isHidden = true
        }
#endif
        player?.startVideo(url)
        player?.play()
    }
    
    open func setupOverlay() {
        overlayView = ITGOverlayView(frame: view.frame)
        overlayView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView!)
        view.sendSubviewToBack(overlayView!)
#if os(iOS)
        let interfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation ?? view.window?.windowScene?.interfaceOrientation
        if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight {
            overlayView?.constraintsFillSuperview()
        } else {
            overlayView?.constraintsFillSuperview(verticalToSafeArea: true)
        }
#else
        overlayView?.constraintsFillSuperview()
#endif
        if shouldResetOverlayUser {
            overlayView?.resetUser()
        }
        overlayView?.load(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, delegate: self, foreignId: foreignId, videoView: player!.getPlayerView()!, vars: vars, enableLogs: enableLogs)
    }
    
    @objc open func closeButtonPressed(_ sender: Any) {
        if let navigationController {
            navigationController.popViewController(animated: true)
            removePlayer()
        } else if let _ = presentingViewController {
            dismiss(animated: true) {
                self.removePlayer()
            }
        }
    }
    
    @objc open func remoteMenuButtonAction(recognizer: UITapGestureRecognizer) {
        //adding gesture for menu button disables passing menu key event further up on responder chain
    }
    
    func removePlayer() {
        player?.pause()
        player?.getPlayerView()?.removeFromSuperview()
        player = nil
    }
    
#if os(tvOS)
    open override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            switch press.type {
            case .menu:
                let backButtonHandled = overlayView?.closeInteractionIfNeeded() ?? false
                if !backButtonHandled {
                    closeButtonPressed(self)
                }
            default:
                super.pressesBegan(presses, with: event)
            }
        }
    }
#endif
    
    private func configureRemoteButtonsHandlers() {
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(remoteMenuButtonAction(recognizer:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(menuPressRecognizer)
    }
    
    private func moveFocusToPlayerView() {
        if player?.getPlayerView()?.deepSubviews().contains(where: { $0.isFocused }) == true {
            return
        }
        if let environments = player?.getPlayerView()?.preferredFocusEnvironments, !environments.isEmpty {
            customPreferredFocusEnvironments = environments
        } else if let environments = player?.getPlayerView()?.deepSubviews().first(where:{ String(describing: type(of: $0)) == "_AVPlayerViewControllerContainerView" })?.preferredFocusEnvironments {
            customPreferredFocusEnvironments = environments
        } else {
            customPreferredFocusEnvironments = nil
        }
        view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
    }
    
#if os(iOS)
    @objc private func orientationDidChange() {
        let interfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation ?? view.window?.windowScene?.interfaceOrientation
        if let constraint = view.constraints.first(where: { $0.firstItem as? ITGOverlayView == overlayView && $0.firstAttribute == .bottom }) {
            view.removeConstraint(constraint)
        }
        if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight {
            overlayView?.constraintsFillSuperview(top: nil, leading: nil, trailing: nil)
        } else {
            overlayView?.constraintsFillSuperview(top: nil, leading: nil, trailing: nil, verticalToSafeArea: true)
        }
    }
#endif
    
    open func videoPlaying(_ time: TimeInterval) {
        overlayView?.videoPlaying(time: time)
        if !didSetInitialFocus {
            moveFocusToPlayerView()
        }
    }
    
    open func videoPaused(_ time: TimeInterval, userInitiated: Bool, isSeeking: Bool) {
        overlayView?.videoPaused(time: time, userInitiated: userInitiated, isSeeking: isSeeking)
    }
    
    open func videoControllsVisibilityChanged(_ isVisible: Bool) {
        controllsVisible = isVisible
#if os(tvOS)
        if #available(tvOS 15.0, *) {
            toggleOverlayBlock(view.window?.windowScene?.focusSystem?.focusedItem as? UIView)
        }
#endif
#if os(iOS)
        if closeButtonVisibilityMode == .whilePlayerControlsVisible {
            closeButton.isHidden = !isVisible
        }
#endif
    }
    
    open func overlayDidPresentContent(_ content: ITGContent) {

    }
    
    open func overlayDidEndPresentingContent(_ content: ITGContent) {

    }
        
    open func overlayDidLoadChannelInfo(_ videoUrl: String?) {
        guard shouldPlayChannelVideo, let videoUrl = videoUrl, let url =  URL(string: videoUrl) else { return }
        startVideo(url)
    }
    
    open func userState(_ user: User) {
        
    }
    
    open func overlayDidProcessAnalyticEvent(info: AnalyticsInfo, type: AnalyticsEventType) {
        
    }
    
    open func overlayRequestedVideoResolution() -> CGSize {
        return player?.getVideoResolution() ?? .zero
    }
    
    open func overlayReceivedDeeplink(_ link: String) {
        
    }
    
    open func overlayRequestedPause() {
        player?.pause()
    }
    
    open func overlayRequestedPlay() {
        player?.play()
    }
    
    open func overlayRequestedFocus() {
        customPreferredFocusEnvironments = [overlayView!]
        view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
    }
    
    open func overlayReleasedFocus() {
        moveFocusToPlayerView()
    }
    
    open func overlayRequestedVideoTime() {
        guard let player = player else { return }
        if player.isPlaying() {
            overlayView?.videoPlaying(time: player.getCurrentTime())
        } else {
            overlayView?.videoPaused(time: player.getCurrentTime())
        }
    }
    
    open func overlayRequestedVideoSeek(time: TimeInterval) {
        player?.seek(time)
    }
    
    open func overlayRequestedVideoLength() -> TimeInterval {
        return player?.getVideoLength() ?? 0
    }
    
    open func overlayRequestedVideoGravity(_ videoGravity: AVLayerVideoGravity) {
        player?.setVideoGravity(videoGravity)
    }
    
    open func overlayRequestedResetVideoGravity() {
        player?.setVideoGravity(.resizeAspect)
    }
    
    open func overlayRequestedVideoSoundLevel(_ soundLevel: Float) {
        self.soundLevel = player?.getSoundLevel() ?? 1
        player?.setSoundLevel(soundLevel)
    }
    
    open func overlayRequestedResetVideoSoundLevel() {
        player?.setSoundLevel(soundLevel)
    }
    
    open func overlayWillChangeVideoRect(_ rect: CGRect, animationDuration: TimeInterval) {

    }
    
    open func overlayWillResetVideoRect(_ animationDuration: TimeInterval) {

    }
    
}
