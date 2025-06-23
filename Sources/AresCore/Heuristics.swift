//
//  Heuristics.swift
//  AresCore
//
//  Created by Joao Pires on 2025-06-23.
//

import Foundation
import SwiftSoup
import Playgrounds

public struct Heuristics {
    
    static func hostPageURL(from feedURLString: String) -> String {
        guard var components = URLComponents(string: feedURLString),
              let host = components.host else {
            return ""
        }

        components.query = nil
        components.fragment = nil

        let feedIndicators: Set<String> = [
            "feed", "rss", "atom", "feeds", "rss.xml", "feed.xml", "index.xml", "feed.rss"
        ]

        var pathSegments = components.path
            .split(separator: "/")
            .map { $0.lowercased() }

        if let last = pathSegments.last, feedIndicators.contains(last) {
            pathSegments.removeLast()
        }

        if host.hasPrefix("feeds.") {
            components.host = String(host.dropFirst("feeds.".count))
        } else if host.hasPrefix("rss.") {
            components.host = String(host.dropFirst("rss.".count))
        }

        components.path = pathSegments.isEmpty ? "" : "/" + pathSegments.joined(separator: "/")

        return components.string ?? ""
    }
    
    static func firstImage(from content: String?) -> String? {
        guard let content else { return nil }
        guard let document: Document = try? SwiftSoup.parse(content.htmlDecoded) else { return nil }
        guard let images = try? document.select("img") else { return nil }
        for image in images {
            do {
                let source = try image.attr("src")
                if source.contains("https://s.w.org/images/core/emoji") { continue }
                else { return source }
            }
            catch { continue }
        }
        return nil

    }
    
    static func icon(from iconString: String?, fromHostURL: String) -> String {
        guard let iconString else {
            return "https://icons.duckduckgo.com/ip3/\(fromHostURL).ico"
        }
        return iconString
    }
}
