//
//  Inthegametv
//

#if os(tvOS)
import Inthegametv
#else
import InthegametviOS
#endif
import Foundation
import MediaTailorSDK

//Note: player should play link provided by plugin otherwise there will be no ads
//Note: don't forget to add GoogleProgrammaticAccessLibrary to project as per Datazoom documentation otherwise crash will have place

public class ITGDatazoomPlugin: AdObserver {
    
    public weak var flexiDelegate: ITGOverlayView?
    
    public init(flexiDelegate: ITGOverlayView) {
        self.flexiDelegate = flexiDelegate
    }
    
    public override func onNewNonLinearAds(adData: NonLinearAdsData) {
        if let availId = adData.availId, let ads = kotlinArrayToArray(adData.nonLinearAdList) {
            let duration = adData.duration
            let time = adData.startDate
            var trackingImpressions: [String] = kotlinArrayToArray(adData.trackingEvents)?.filter({ $0.eventType == "impression" }).compactMap({ kotlinArrayToArray( $0.beaconUrls) }).flatMap({ $0 }) as? [String] ?? []
            var trackingErrors: [String] = kotlinArrayToArray(adData.trackingEvents)?.filter({ $0.eventType == "error" }).compactMap({ kotlinArrayToArray( $0.beaconUrls) }).flatMap({ $0 }) as? [String] ?? []
            trackingImpressions = trackingImpressions.filter({ removeCDATA(from: $0) != "www.example.com" && removeCDATA(from: $0 as String) != "https://www.example.com" })
            trackingErrors = trackingErrors.filter({ removeCDATA(from: $0) != "www.example.com" && removeCDATA(from: $0) != "https://www.example.com" })
            parseAds(ads, time: time, availId: availId, duration: duration, trackingUrls: trackingImpressions as [String], errorUrls: trackingErrors as [String], completion: { [weak self] flexis in
                if let flexis {
                    self?.flexiDelegate?.scheduleFlexi(flexis, time: time)
                }
            })
        }
    }
        
    private func parseAds(_ ads: [NonLinearAdsData.NonLinearAd], time: Double, availId: String, duration: Double?, trackingUrls: [String]?, errorUrls: [String]?, completion: @escaping ([String]?)->Void) {
        for ad in ads {
            if ad.staticResourceCreativeType == "inthegame_creative" {
                if let flexiString = ad.staticResource {
                    processFlexis(flexiString, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls, completion: completion)
                }
            }
        }
    }
    
    private func processFlexis(_ flexis: String, duration: Double?, trackingUrls: [String]?, errorUrls: [String]?, completion: @escaping ([String]?)->Void) {
        let data = Data(flexis.utf8)
        if let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            var result: [String] = []
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            dispatchGroup.notify(queue: .main, execute: {
                completion(result)
            })
            for json in array {
                if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
                    dispatchGroup.enter()
                    let jsonString = String(data: data, encoding: .utf8)!
                    processFlexi(jsonString, duration: nil, trackingUrls: trackingUrls, errorUrls: errorUrls) { flexi in
                        if let flexi {
                            result.append(flexi)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.leave()
        } else {
            processFlexi(flexis, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls) { flexi in
                if let flexi {
                    completion([flexi])
                }
                completion(nil)
            }
        }
    }
    
    private func processFlexi(_ flexi: String, duration: Double?, trackingUrls: [String]?, errorUrls: [String]?, completion: @escaping (String?)->Void) {
        let flexiString = removeCDATA(from: removeADataTag(from: flexi))
        if isValidUrl(flexiString), let url = URL(string: flexiString) {
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
        if let duration, duration != 0, general["duration"] == nil {
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
    
    private func kotlinArrayToArray<T>(_ array: KotlinArray<T>?) -> Array<T>? {
        guard let array else { return nil }
        var result = [T]()
        for index in 0..<array.size {
            if let item = array.get(index: index) {
                result.append(item)
            }
        }
        return result
    }
    
    private func isValidUrl(_ string: String) -> Bool {
        guard !string.contains("..") else { return false }
        let head     = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail     = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
        let urlRegEx = head+"+(.)+"+tail
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: string.trimmingCharacters(in: .whitespaces))
    }
    
}
