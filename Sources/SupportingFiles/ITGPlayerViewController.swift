//
//  Inthegametv
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
    public var shouldPlayChannelVideo: Bool = false
    private var customPreferredFocusEnvironments: [any UIFocusEnvironment]?
    private var player: ITGPlayerAdapter?
    private var controllsVisible: Bool = false
    private var channelSlug: String
    private var virtualChannels: [String]?
    private var accountId: String
    private var environment: ITGEnvironment
    private var foreignId: String?
    private var shouldResetOverlayUser: Bool
    private var soundLevel: Float? = nil
    private var vars: [String: Any]? = nil
    private var adsMetadata: [AdMetadata]?
    private var showLogs: Bool
    private var originalVideoGravity: AVLayerVideoGravity?
#if os(iOS)
    private var previousOrientationLandscape: Bool?
#endif
    
    public init(channelSlug: String, virtualChannels: [String]? = nil, accountId: String, environment: ITGEnvironment = ITGEnvironment.defaultEnvironment, foreignId: String? = nil, vars: [String: any Hashable]? = nil, adsMetadata: [AdMetadata]? = nil, playerAdapter: ITGPlayerAdapter, shouldResetOverlayUser: Bool = false, showLogs: Bool = false) {
        self.channelSlug = channelSlug
        self.virtualChannels = virtualChannels
        self.accountId = accountId
        self.environment = environment
        self.foreignId = foreignId
        self.shouldResetOverlayUser = shouldResetOverlayUser
        self.player = playerAdapter
        self.vars = vars
        self.adsMetadata = adsMetadata
        self.showLogs = showLogs
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removePlayer()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
#if os(tvOS)
        configureRemoteButtonsHandlers()
#else
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
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
        orientationDidChange()
#endif
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parentFocusEnvironment?.setNeedsFocusUpdate()
        parentFocusEnvironment?.updateFocusIfNeeded()
    }
    
#if os(iOS)
    open override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        if view.window != nil {
            orientationDidChange()
        }
    }
#endif
    
    open func reloadChannel(channelSlug: String, virtualChannels: [String]? = nil, accountId: String, environment: ITGEnvironment = ITGEnvironment.defaultEnvironment, foreignId: String? = nil, vars: [String: any Hashable]? = nil, playerAdapter: ITGPlayerAdapter, shouldResetOverlayUser: Bool = false, adsMetadata: [AdMetadata]? = nil, showLogs: Bool = false) {
        self.channelSlug = channelSlug
        self.virtualChannels = virtualChannels
        self.accountId = accountId
        self.environment = environment
        self.foreignId = foreignId
        self.shouldResetOverlayUser = shouldResetOverlayUser
        self.player = playerAdapter
        self.vars = vars
        self.adsMetadata = adsMetadata
        self.showLogs = showLogs
        if shouldResetOverlayUser {
            overlayView?.resetUser()
        }
        overlayView?.load(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, delegate: self, foreignId: foreignId, vars: vars, adsMetadata: adsMetadata, showLogs: showLogs)
    }
    
    open func setupPlayer() {
        if let playerView = player?.getPlayerView() {
            customPreferredFocusEnvironments = playerView.preferredFocusEnvironments
            playerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(playerView)
#if os(iOS)
            let interfaceOrientation: UIInterfaceOrientation?
            if #available(tvOS 13.0, iOS 13.0, *) {
                interfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation
            } else {
                interfaceOrientation = UIApplication.shared.statusBarOrientation
            }
            if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight {
                playerView.constraintsFillSuperview()
            } else {
                playerView.constraintsFillSuperview(verticalToSafeArea: true)
            }
#else
            playerView.constraintsFillSuperview()
#endif
            view.bringSubviewToFront(overlayView!)
        }
#if os(iOS)
        orientationDidChange()
#endif
        view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
    }
    
    open func startVideo(_ url: URL) {
#if os(iOS)
        if closeButtonVisibilityMode != .always {
            closeButton.isHidden = true
        }
#endif
        player?.startVideo(url)
    }
    
    open func setupOverlay() {
        overlayView = ITGOverlayView(frame: view.frame)
        overlayView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView!)
        view.sendSubviewToBack(overlayView!)
#if os(iOS)
        let interfaceOrientation: UIInterfaceOrientation?
        if #available(tvOS 13.0, iOS 13.0, *) {
            interfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation
        } else {
            interfaceOrientation = UIApplication.shared.statusBarOrientation
        }
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
        overlayView?.load(channelSlug: channelSlug, virtualChannels: virtualChannels, accountId: accountId, environment: environment, delegate: self, foreignId: foreignId, vars: vars, adsMetadata: adsMetadata, showLogs: showLogs)
    }
    
    @objc open func closeButtonPressed(_ sender: Any) {
        _ = overlayView?.close(true)
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
        let backButtonHandled = overlayView?.close() ?? false
        if !backButtonHandled {
            closeButtonPressed(self)
        }
    }
    
    @objc open func remotePlayPauseButtonAction(recognizer: UITapGestureRecognizer) {
        _ = overlayView?.close(true)
        if player?.isPlaying() == true {
            player?.pause()
        } else {
            player?.play()
            moveFocusToPlayerView()
        }
    }
    
    @objc open func remoteSelectButtonAction(recognizer: UITapGestureRecognizer) {
        let focusedItem: UIView?
        if #available(tvOS 15.0, iOS 15.0, *) {
            focusedItem = view.window?.windowScene?.focusSystem?.focusedItem as? UIView
        } else {
            focusedItem = UIScreen.main.focusedView
        }
        if let overlayView, focusedItem?.isDescendant(of: overlayView) != true {
            _ = overlayView.close(true)
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
        let playpausePressRecognizer = UITapGestureRecognizer()
        playpausePressRecognizer.addTarget(self, action: #selector(remotePlayPauseButtonAction(recognizer:)))
        playpausePressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        view.addGestureRecognizer(playpausePressRecognizer)
        let selectPressRecognizer = UITapGestureRecognizer()
        selectPressRecognizer.addTarget(self, action: #selector(remoteSelectButtonAction(recognizer:)))
        selectPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        view.addGestureRecognizer(selectPressRecognizer)
    }
    
    private func moveFocusToPlayerView() {
        if player?.getPlayerView()?.deepSubviews().contains(where: { $0.isFocused }) == true {
            return
        }
        customPreferredFocusEnvironments = player?.getPlayerView()?.preferredFocusEnvironments
        view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
    }
    
#if os(iOS)
    @objc private func orientationDidChange() {
        let interfaceOrientation: UIInterfaceOrientation?
        if #available(tvOS 13.0, iOS 13.0, *) {
            interfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation
        } else {
            interfaceOrientation = UIApplication.shared.statusBarOrientation
        }
        let isLandscapeOrientation = interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight
        if previousOrientationLandscape != isLandscapeOrientation {
            view.constraints.filter({ $0.firstItem is ITGOverlayView }).forEach {
                view.removeConstraint($0)
            }
            view.constraints.filter({ $0.firstItem as? UIView == player?.getPlayerView() }).forEach {
                view.removeConstraint($0)
            }
            player?.getPlayerView()?.layer.removeAllAnimations()
            if isLandscapeOrientation {
                overlayView?.constraintsFillSuperview()
                player?.getPlayerView()?.constraintsFillSuperview()
            } else {
                overlayView?.constraintsFillSuperview(verticalToSafeArea: true)
                player?.getPlayerView()?.constraintsFillSuperview(verticalToSafeArea: true)
            }
        }
        previousOrientationLandscape = isLandscapeOrientation
    }
#endif
    
    open func videoPlaying(_ time: TimeInterval) {
        overlayView?.playerChangedState(videoState())
    }
    
    open func videoPaused(_ time: TimeInterval, userInitiated: Bool, isSeeking: Bool) {
        overlayView?.playerChangedState(videoState(), userInitiated: userInitiated, isSeeking: isSeeking)
    }
    
    open func videoControllsVisibilityChanged(_ isVisible: Bool) {
        controllsVisible = isVisible
#if os(iOS)
        if closeButtonVisibilityMode == .whilePlayerControlsVisible {
            closeButton.isHidden = !isVisible
        }
#endif
    }
    
    open func videoState() -> ITGVideoState {
        return ITGVideoState(videoDuration: player?.getVideoLength() ?? 0, videoTime: player?.getCurrentTime() ?? 0, videoStatus: player?.isPlaying() == true ? .playing :  .paused, visibleContent: .content, adMetadata: nil)
    }
    
    open func itgDidLoadChannelInfo(_ channelMeta: ChannelMeta) {
        guard shouldPlayChannelVideo, !channelMeta.streamUrl.isEmpty, let url =  URL(string: channelMeta.streamUrl) else { return }
        startVideo(url)
    }
    
    open func itgRequestedVideoStateChange(_ state: ITGPlayerState, timeStamp: TimeInterval?) {
        if let timeStamp {
            player?.seek(timeStamp)
        }
        if state == .playing {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    open func itgRequestedFocusUpdate(_ focusRequired: Bool) {
        if focusRequired {
            customPreferredFocusEnvironments = [overlayView!]
            view.setNeedsFocusUpdate()
            view.updateFocusIfNeeded()
        } else {
            moveFocusToPlayerView()
        }
    }
    
    open func itgRequestedVideoRectChange(_ rect: CGRect?, animationTime: TimeInterval) {
        func animateVideoTransformation(_ layer: CALayer, duration: TimeInterval, transform: CATransform3D, removeOnCompletion: Bool) {
            let animation = CABasicAnimation(keyPath: "transform")
            animation.toValue = transform
            if duration == 0 {
                animation.fromValue = animation.toValue
            } else {
                animation.fromValue = layer.presentation()?.transform
            }
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.isRemovedOnCompletion = removeOnCompletion
            animation.duration = duration
            layer.add(animation, forKey: "flexiVideoTransform")
        }
        if let rect {
            if let videoView = player?.getPlayerView(), let overlayView {
                let xScale = rect.size.width/overlayView.frame.size.width
                let yScale = rect.size.height/overlayView.frame.size.height
                let xTranslation = rect.origin.x + rect.width/2 - videoView.bounds.width/2
                let yTranslation = rect.origin.y + rect.height/2 - videoView.bounds.height/2
                let videoViewTransform = CGAffineTransform.identity.translatedBy(x: xTranslation, y: yTranslation).scaledBy(x: xScale, y: yScale)
                animateVideoTransformation(videoView.layer, duration: animationTime, transform: CATransform3DMakeAffineTransform(videoViewTransform), removeOnCompletion: false)
            }
        } else {
            if let videoView = player?.getPlayerView() {
                animateVideoTransformation(videoView.layer, duration: animationTime, transform: CATransform3DIdentity, removeOnCompletion: true)
            }
        }
    }
    
    open func itgReceivedDeeplink(_ link: String) {
        
    }
    
    open func itgDidProcessAnalyticEvent(info: AnalyticsInfo, type: AnalyticsEventType) {
        print(info)
    }
    
    open func itgDidUpdateUserState(_ user: User) {
        
    }
    
    open func itgRequestedVideoSoundLevel(_ soundLevel: Float?) {
        if let soundLevel {
            if self.soundLevel == nil {
                self.soundLevel = player?.getSoundLevel() ?? 1
            }
            player?.setSoundLevel(soundLevel)
        } else if let soundLevel = self.soundLevel {
            player?.setSoundLevel(soundLevel)
            self.soundLevel = nil
        }
    }
    
    open func itgRequestedVideoGravity(_ videoGravity: AVLayerVideoGravity?) {
        if let videoGravity {
            if originalVideoGravity == nil {
                originalVideoGravity = player?.getVideoGravity()
            }
            player?.setVideoGravity(videoGravity)
        } else if let originalVideoGravity {
            player?.setVideoGravity(originalVideoGravity)
            self.originalVideoGravity = nil
        }
    }
    
    open func itgWillPresentAd(event: ITGAdEvent) {
        
    }
    
    open func itgDidFinishPresentingAd(event: ITGAdEvent) {
        
    }
    
}
