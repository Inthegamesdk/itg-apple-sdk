//
//  Inthegametv
//

#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif
import GoogleInteractiveMediaAds
import Foundation

public class ITGGoogleIMAPlugin: NSObject, ITGGoogleIMAPluginProtocol {
    
    private let adsLoader = IMAAdsLoader()
    private var adsManager: IMAAdsManager?
    private weak var delegate: ITGGoogleIMAPluginDelegate?
    private var savedTime: TimeInterval?
    
    public func requestAd(_ url: String, videoView: UIView, viewController: UIViewController, delegate: ITGGoogleIMAPluginDelegate) {
        self.delegate = delegate
        adsLoader.delegate = self
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: videoView, viewController: viewController)
        let request = IMAAdsRequest(adTagUrl: url, adDisplayContainer: adDisplayContainer, contentPlayhead: nil, userContext: nil)
        adsLoader.requestAds(with: request)
    }
    
    public func close() {
        adsManager?.destroy()
        delegate?.requestResume(savedTime)
        delegate?.addDidFinish()
        savedTime = nil
    }
    
}

extension ITGGoogleIMAPlugin: IMAAdsLoaderDelegate {
    
    public func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsManager?.initialize(with: adsRenderingSettings)
    }
    
    public func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        delegate?.didFailedToLoadAd(adErrorData.adError.message)
    }
    
}

extension ITGGoogleIMAPlugin: IMAAdsManagerDelegate {
    
    public func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        if event.type == IMAAdEventType.LOADED {
            delegate?.adInfo(event.ad?.isSkippable == true)
            adsManager.start()
        }
        if event.type == IMAAdEventType.COMPLETE {
            delegate?.addDidFinish()
        }
    }
    
    public func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        delegate?.didFailedToLoadAd(error.message)
        savedTime = nil
    }
    
    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        savedTime = delegate?.requestPause()
    }
    
    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        delegate?.requestResume(savedTime)
        savedTime = nil
    }
    
}
