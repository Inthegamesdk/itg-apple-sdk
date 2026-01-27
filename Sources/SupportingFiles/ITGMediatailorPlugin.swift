//
//  Inthegametv
//

#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif
import Foundation

public protocol ITGMediatailorPluginDelegate: AnyObject {
    
    func didReceiveTrackingData(_ jsonData : [String: Any])
    
}

public class ITGMediatailorPlugin {
    
    public weak var dataDelegate: ITGMediatailorPluginDelegate?
    public weak var flexiDelegate: ITGOverlayView?
    private var updateTimer: Timer?
    private var processedAvails: [(String, Date)] = []
    private var idTimer: Timer?
    private var notifyDataDelegateOperation: (()->Void)?
    
    deinit {
        updateTimer?.invalidate()
        idTimer?.invalidate()
    }
    
    public init(dataDelegate: ITGMediatailorPluginDelegate?, flexiDelegate: ITGOverlayView) {
        self.dataDelegate = dataDelegate
        self.flexiDelegate = flexiDelegate
    }
    
    public func startMediaTailor(url: String, interval: Int) {
        updateTimer?.invalidate()
        idTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
            self.processedAvails = self.processedAvails.filter({ abs($0.1.timeIntervalSinceNow) < 60 }) 
        })
        updateTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true, block: { _ in
            if let url = URL(string: url) {
                URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
                    DispatchQueue.main.async {
                        if let data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            self?.parseData(json)
                        }
                    }
                }.resume()
            }
        })
    }
    
    public func stopMediaTailor() {
        updateTimer?.invalidate()
        idTimer?.invalidate()
    }
    
    private func processFlexi(_ flexi: String, duration: Double?, trackingUrls: [String]?, errorUrls: [String]?, completion: @escaping (String?)->Void) {
        let flexiString = removeCDATA(from: removeADataTag(from: flexi))
        if flexiString.isValidUrl(), let url = URL(string: flexiString) {
            URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
                if let data, let flexiJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let flexi = self?.decorateFlexi(flexiJson, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls) {
                    completion(flexi)
                } else {
                    completion(nil)
                }
            }.resume()
        } else if let flexiJson = try? JSONSerialization.jsonObject(with: flexiString.data(using: .utf8)!) as? [String: Any], let flexi = decorateFlexi(flexiJson, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls) {
            completion(flexi)
        } else {
            completion(nil)
        }
    }
    
    private func decorateFlexi(_ flexi: [String: Any], duration: Double?, trackingUrls: [String]?, errorUrls: [String]?) -> String? {
        var flexi = flexi
        var general = flexi["general"] as? [String: Any] ?? [:]
        if let duration, duration != 0 {
            general["duration"] = "\(duration)"
        }
        if let trackingUrls {
            var analytics = general["analytics"] as? [String: Any] ?? [:]
            if !(analytics["impression"] is String) {
                var impressions = analytics["impression"] as? [String] ?? []
                impressions.append(contentsOf: trackingUrls)
                analytics["impression"] = impressions
                general["analytics"] = analytics
            }
        }
        if let errorUrls {
            var analytics = general["analytics"] as? [String: Any] ?? [:]
            if !(analytics["error"] is String) {
                var errors = analytics["error"] as? [String] ?? []
                errors.append(contentsOf: errorUrls)
                analytics["error"] = errors
                general["analytics"] = analytics
            }
        }
        flexi["general"] = general
        return jsonToString(flexi)
    }
    
    private func parseAds(_ ads: [[String: Any]], time: Double, availId: String, duration: Double?, dispatchGroup: DispatchGroup, completion: @escaping (String?)->Void) {
        for ad in ads {
            var trackingUrls = (ad["trackingEvents"] as? [[String: Any]])?.filter({ $0["eventType"] as? String == "impression" }).compactMap({ $0["beaconUrls"] as? [String] }).flatMap({ $0 })
            var errorUrls = (ad["trackingEvents"] as? [[String: Any]])?.filter({ $0["eventType"] as? String == "error" }).compactMap({ $0["beaconUrls"] as? [String] }).flatMap({ $0 })
            trackingUrls = trackingUrls?.filter({ removeCDATA(from: $0) != "www.example.com" && removeCDATA(from: $0 as String) != "https://www.example.com" })
            errorUrls = errorUrls?.filter({ removeCDATA(from: $0) != "www.example.com" && removeCDATA(from: $0) != "https://www.example.com" })
            for ext in ad["extensions"] as? [[String: Any]] ?? [] {
                if ext["type"] as? String == "inthegame_creative" {
                    if let flexiString = ext["content"] as? String {
                        dispatchGroup.enter()
                        processFlexi(flexiString, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls, completion: completion)
                    }
                }
            }
            for nonLinearAd in ad["nonLinearAdList"] as? [[String: Any]] ?? [] {
                if nonLinearAd["staticResourceCreativeType"] as? String == "inthegame_creative" {
                    if let flexiString = nonLinearAd["staticResource"] as? String {
                        dispatchGroup.enter()
                        processFlexi(flexiString, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls, completion: completion)
                    }
                }
            }
        }
    }
    
    private func parseAvails(_ avails: [[String: Any]]) {
        for avail in avails {
            if let availId = avail["availId"] as? String, !processedAvails.contains(where: { $0.0 == availId }) {
                var flexis: [String] = []
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                processedAvails.append((availId, Date()))
                notifyDataDelegateOperation?()
                notifyDataDelegateOperation = nil
                let time = avail["startTimeInSeconds"] as? Double ?? 0
                let duration = avail["durationInSeconds"] as? Double
                let completion: (String?)->Void = { flexi in
                    if let flexi {
                        flexis.append(flexi)
                    }
                    dispatchGroup.leave()
                }
                if let ads = avail["ads"] as? [[String: Any]] {
                    parseAds(ads, time: time, availId: availId, duration: duration, dispatchGroup: dispatchGroup, completion: completion)
                }
                if let ads = avail["nonLinearAdsList"] as? [[String: Any]] {
                    parseAds(ads, time: time, availId: availId, duration: duration, dispatchGroup: dispatchGroup, completion: completion)
                }
                dispatchGroup.notify(queue: .main) { [weak self] in
                    self?.flexiDelegate?.scheduleFlexi(flexis, time: time)
                }
                dispatchGroup.leave()
            }
        }
    }
    
    private func parseData(_ json: [String: Any]) {
        notifyDataDelegateOperation = { [weak self] in
            self?.dataDelegate?.didReceiveTrackingData(json)
        }
        if let avails = json["avails"] as? [[String: Any]] {
            parseAvails(avails)
        }
        if let avails = json["nonLinearAvails"] as? [[String: Any]] {
            parseAvails(avails)
        }
    }
    
    private func removeCDATA(from string: String) -> String {
        return string.replacingOccurrences(of: "<![CDATA[", with: "").replacingOccurrences(of: "]]>", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func removeADataTag(from string: String) -> String {
        return string.replacingOccurrences(of: "<AdData>", with: "").replacingOccurrences(of: "</AdData>", with: "").replacingOccurrences(of: "<adData>", with: "").replacingOccurrences(of: "</adData>", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func jsonToString(_ json: Any) -> String? {
        guard JSONSerialization.isValidJSONObject(json), let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
}

extension String {
    
    func isValidUrl() -> Bool {
        guard !contains("..") else { return false }
        let head     = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail     = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
        let urlRegEx = head+"+(.)+"+tail
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: trimmingCharacters(in: .whitespaces))
    }
    
}
