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
    
    static func sanitize(_ string: String?) -> String? {
        guard var string = string else {
            return string
        }
        let entities: [(String, String)] = [
            ("&amp;", "&"),
            ("&apos;", "'"),
            ("&quot;", "\""),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&#8211;", "–"),
            ("&#8212;", "—"),
            ("&#8216;", "‘"),
            ("&#8217;", "’"),
            ("&#8220;", "“"),
            ("&#8221;", "”"),
            ("&#8230;", "…"),
            ("&nbsp;", " "),
        ]
        for (entity, character) in entities {
            string = string.replacingOccurrences(of: entity, with: character)
        }
        return string
    }
    
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
    
    static func safeAuthors(from authors: [String?]) -> String {
        var authorsString = [String]()
        for author in authors {
            if var authorString = sanitize(author) {
                authorString = authorString.replacingOccurrences(of: "\n", with: "")
                authorsString.append(authorString)
            }
        }
        return authorsString.joined(separator: ", ")
    }

    
    static func safeAuthors(from authors: String?...) -> String {
        return safeAuthors(from: authors)
    }
    
    static func safeTitle(from title: String?) -> String? {
        return sanitize(title)
    }
    
    static func safeContent(from content: String?) -> String? {
        return sanitize(content)
    }
}
