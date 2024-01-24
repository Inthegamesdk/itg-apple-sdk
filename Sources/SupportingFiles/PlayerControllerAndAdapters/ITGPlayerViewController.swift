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
    
    lazy var closeButton: UIButton? = {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "close"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.tintColor = .white
        return button
    }()
    open override var preferredFocusedView: UIView? {
        return customPreferredFocusView
    }
#if os(iOS)
    open override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
#endif
    public var overlayView: ITGOverlayView?
    public var autoBlock: ITGOverlayView.AutoBlockMode = .disabled
    public var autoBlockDisregard: Set<UIView> = []
    private weak var customPreferredFocusView: UIView?
    private var player: ITGPlayerAdapter?
    private var controllsVisible: Bool = false
    private var channelSlug: String
    private var secondaryChannelSlug: String?
    private var accountId: String
    private var environment: ITGEnvironment
    private var language: String?
    private var foreignId: String?
    private var userName: String?
    private var userAvatar: String?
    private var userEmail: String?
    private var userPhone: String?
    private var userRole: UserRole
    private var useWebp: Bool = false
    private var shouldResetOverlayUser: Bool
    private var soundLevel: Float = 1
    private var vars: [String: Any]? = nil
    
    public init(channelSlug: String, secondaryChannelSlug: String? = nil, accountId: String, environment: ITGEnvironment = ITGEnvironment.defaultEnvironment, language: String = "en", foreignId: String? = nil, userName: String? = nil, userAvatar: String? = nil, userEmail: String? = nil, userPhone: String? = nil, userRole: UserRole = .user, useWebp: Bool = false, vars: [String: Any]? = nil, playerAdapter: ITGPlayerAdapter, shouldResetOverlayUser: Bool = false) {
        self.channelSlug = channelSlug
        self.secondaryChannelSlug = secondaryChannelSlug
        self.accountId = accountId
        self.environment = environment
        self.language = language
        self.foreignId = foreignId
        self.userName = userName
        self.userAvatar = userAvatar
        self.userRole = userRole
        self.userEmail = userEmail
        self.userPhone = userPhone
        self.shouldResetOverlayUser = shouldResetOverlayUser
        self.player = playerAdapter
        self.useWebp = useWebp
        self.vars = vars
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        view.addSubview(closeButton!)
        closeButton?.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 40).isActive = true
        closeButton?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
#endif
        setupOverlay()
        setupPlayer()
        player?.delegate = self
    }
    
#if os(iOS)
    open override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        if view.window == nil {
            orientationDidChange()
        }
    }
#endif
    
    open func toggleOverlayBlock(_ focusedItem: UIView?) {
        if autoBlock == .auto, let overlayView = self.overlayView, let playerView = player?.getPlayerView() {
            overlayView.autoBlockValue = focusedItem != nil && (focusedItem?.isDescendant(of: overlayView) != true || (focusedItem?.isDescendant(of: playerView) == true && controllsVisible) && !autoBlockDisregard.contains(where: { focusedItem?.isDescendant(of: $0) == true }))
        }
    }
    
    open func setupPlayer() {
        if let playerView = player?.getPlayerView() {
            customPreferredFocusView = playerView
        }
#if os(iOS)
        orientationDidChange()
#endif
        view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
    }
    
    open func startVideo(_ url: URL) {
        closeButton?.isHidden = true
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
        overlayView?.load(channelSlug: channelSlug, secondaryChannelSlug: secondaryChannelSlug, accountId: accountId, environment: environment, delegate: self, language: language!, foreignId: foreignId, userName: userName, userAvatar: userAvatar, userPhone: userPhone, userRole: userRole, videoView: player!.getPlayerView()!, useWebp: useWebp, vars: vars)
        overlayView?.injectionDelay = nil
    }
    
    @objc open func closeButtonPressed(_ sender: Any) {
        if let navigationController {
            navigationController.popViewController(animated: true)
            removePlayer()
        } else {
            dismiss(animated: true) {
                self.removePlayer()
            }
        }
    }
    
    @objc open func remoteMenuButtonAction(recognizer: UITapGestureRecognizer) {
        let backButtonHandled = overlayView?.closeInteractionIfNeeded() ?? false
        if !backButtonHandled {
            closeButtonPressed(self)
        }
    }
    
    @objc open func remotePlayPauseButtonAction(recognizer: UITapGestureRecognizer) {
        overlayView?.closeAll()
        if player?.isPlaying() == true {
            player?.pause()
        } else {
            player?.play()
        }
    }
    
    func removePlayer() {
        player?.pause()
        player?.getPlayerView()?.removeFromSuperview()
        player = nil
    }
    
    private func configureRemoteButtonsHandlers() {
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(remoteMenuButtonAction(recognizer:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(menuPressRecognizer)
        let playPausePressRecognizer = UITapGestureRecognizer()
        playPausePressRecognizer.addTarget(self, action: #selector(remotePlayPauseButtonAction(recognizer:)))
        playPausePressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        view.addGestureRecognizer(playPausePressRecognizer)
    }
    
#if os(iOS)
    @objc private func orientationDidChange() {
        let interfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation ?? view.window?.windowScene?.interfaceOrientation
        if let constraint = view.constraints.first(where: { $0.firstItem as? ITGOverlayView == overlayView && $0.firstAttribute == .bottom }) {
            view.removeConstraint(constraint)
        }
        if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight {
            overlayView?.constraintsFillSuperview(top: nil, leading: nil, trailing: nil)
            if controllsVisible {
                overlayView?.openMenu()
            }
        } else {
            overlayView?.constraintsFillSuperview(top: nil, leading: nil, trailing: nil, verticalToSafeArea: true)
        }
    }
#endif
    
    open func menuButtonAction() {
        guard let overlay = overlayView, overlay.canOpenMenuFromRemote else { return }
        if overlay.isMenuVisible() == true {
            overlay.closeMenu()
        } else {
            overlay.openMenu()
        }
    }
    
    open func videoPlaying(_ time: TimeInterval) {
        overlayView?.videoPlaying(time: time)
    }
    
    open func videoPaused(_ time: TimeInterval) {
        overlayView?.videoPaused(time: time)
    }
    
    open func videoControllsVisibilityChanged(_ isVisible: Bool) {
#if os(iOS)
        let interfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation ?? view.window?.windowScene?.interfaceOrientation
        if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight {
            if isVisible {
                overlayView?.openMenu()
            } else {
                overlayView?.closeMenu()
            }
        }
        closeButton?.isHidden = !isVisible
#endif
        controllsVisible = isVisible
#if os(tvOS)
        if #available(tvOS 15.0, *) {
            toggleOverlayBlock(view.window?.windowScene?.focusSystem?.focusedItem as? UIView)
        }
#endif
    }
    
    open func overlayDidPresentContent(_ content: ITGContent) {

    }
    
    open func overlayDidEndPresentingContent(_ content: ITGContent) {

    }
        
    open func overlayDidLoadChannelInfo(_ videoUrl: String?) {
        guard let videoUrl = videoUrl, let url =  URL(string: videoUrl) else { return }
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
        customPreferredFocusView = overlayView
        view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
    }
    
    open func overlayReleasedFocus() {
        customPreferredFocusView = player?.getPlayerView()
        view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
    }
    
    open func overlayResizeVideoHeight(activityHeight: CGFloat) {
    
    }
    
    open func overlayResetVideoHeight() {
     
    }
    
    open func overlayResizeVideoWidth(activityWidth: CGFloat) {

    }
    
    open func overlayResetVideoWidth() {

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
    
}
