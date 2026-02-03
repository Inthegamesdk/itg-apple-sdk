//
//  MediatailorPlugin.swift
//  Inthegametv
//
//  Created by ilya khymych on 24.12.2025.
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
    
    deinit {
        updateTimer?.invalidate()
        idTimer?.invalidate()
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
                        if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            self?.dataDelegate?.didReceiveTrackingData(json)
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
    
    private func processFlexi(_ flexi: String, time: Double, availId: String, duration: Double?, trackingUrls: [String]?, errorUrls: [String]?) {
        let flexiString = removeCDATA(from: removeADataTag(from: flexi))
        if flexiString.isValidUrl(), let url = URL(string: flexiString) {
            URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
                if let data = data, let flexiJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    self?.scheduleFlexi(flexiJson, time: time, availId: availId, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls)
                }
            }.resume()
        } else if let flexiJson = try? JSONSerialization.jsonObject(with: flexiString.data(using: .utf8)!) as? [String: Any] {
            scheduleFlexi(flexiJson, time: time, availId: availId, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls)
        }
    }
    
    private func scheduleFlexi(_ flexi: [String: Any], time: Double, availId: String, duration: Double?, trackingUrls: [String]?, errorUrls: [String]?) {
        var flexi = flexi
        var launch = flexi["launch"] as? [String: Any] ?? [:]
        if let duration = duration, duration != 0 {
            launch["duration"] = "\(duration)"
        }
        if let trackingUrls = trackingUrls {
            var analytics = launch["analytics"] as? [String: Any] ?? [:]
            var impressions = analytics["impressions"] as? [String] ?? []
            impressions.append(contentsOf: trackingUrls)
            analytics["impressions"] = impressions
            launch["analytics"] = analytics
        }
        if let errorUrls = errorUrls {
            var analytics = launch["analytics"] as? [String: Any] ?? [:]
            var errors = analytics["errors"] as? [String] ?? []
            errors.append(contentsOf: errorUrls)
            analytics["errors"] = errors
            launch["analytics"] = analytics
        }
        flexi["launch"] = launch
        if let flexiString = jsonToString(flexi) {
            processedAvails.append((availId, Date()))
            flexiDelegate?.scheduleFlexi(flexiString, time: time)
        }
    }
    
    private func parseAds(_ ads: [[String: Any]], time: Double, availId: String, duration: Double?) {
        for ad in ads {
            let trackingUrls = (ad["trackingEvents"] as? [[String: Any]])?.filter({ $0["eventType"] as? String == "impression" }).compactMap({ $0["beaconUrls"] as? [String] }).flatMap({ $0 })
            let errorUrls = (ad["trackingEvents"] as? [[String: Any]])?.filter({ $0["eventType"] as? String == "error" }).compactMap({ $0["beaconUrls"] as? [String] }).flatMap({ $0 })
            for ext in ad["extensions"] as? [[String: Any]] ?? [] {
                if ext["type"] as? String == "inthegame_creative", let flexiString = ext["content"] as? String {
                    processFlexi(flexiString, time: time, availId: availId, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls)
                }
            }
            for nonLinearAd in ad["nonLinearAdList"] as? [[String: Any]] ?? [] {
                if nonLinearAd["staticResourceCreativeType"] as? String == "inthegame_creative", let flexiString = nonLinearAd["staticResource"] as? String {
                    processFlexi(flexiString, time: time, availId: availId, duration: duration, trackingUrls: trackingUrls, errorUrls: errorUrls)
                }
            }
        }
    }
    
    private func parseAvails(_ avails: [[String: Any]]) {
        for avail in avails {
            if let availId = avail["availId"] as? String, !processedAvails.contains(where: { $0.0 == availId }) {
                let time = avail["startTimeInSeconds"] as? Double ?? 0
                let duration = avail["durationInSeconds"] as? Double
                if let ads = avail["ads"] as? [[String: Any]] {
                    parseAds(ads, time: time, availId: availId, duration: duration)
                }
                if let ads = avail["nonLinearAdsList"] as? [[String: Any]] {
                    parseAds(ads, time: time, availId: availId, duration: duration)
                }
            }
        }
    }
    
    private func parseData(_ json: [String: Any]) {
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
