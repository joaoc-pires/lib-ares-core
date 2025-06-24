//
//  Heuristics.swift
//  AresCore
//
//  Created by Joao Pires on 2025-06-23.
//

import Foundation
import SwiftSoup
import Playgrounds
import CryptoKit

public struct Heuristics {
    
    /// If you're reading this, you're probably wondering why the hell there's an open string being use for the key of an unsafe, and easily crackable encription.
    /// Let me assure you, it's not because I'm an idiot, although if I am or not it's still something that can be contested.
    /// The key and encription method exist only to generate a unique, deterministic, machine readable ID for both entries and feeds.
    ///
    /// One could always use just title + url, but honestly, what would be the fun in that.
    ///
    /// And if we one sometimes doesn't do something just for the fun of it, what the fuck are we doing on this planet?
    private static let key = "AresCoreLibrary"
    
    public static func generateStableID(from title: String, url: String) -> String {
        let input = "\(url)|\(title)"
        let safeguardKey = UUID().uuidString
        let inputBytes = Array(input.utf8)
        let keyBytes = Array(key.utf8)

        let xorBytes = inputBytes.enumerated().map { i, byte in
            byte ^ keyBytes[i % keyBytes.count]
        }

        // Encode XOR'd bytes to a base64 string for ID
        return Data(xorBytes).base64EncodedString()
    }
    
    public static func decodeId(from idString: String) -> String? {
        guard let data = Data(base64Encoded: idString) else { return nil }
        let keyBytes = Array(key.utf8)

        let decodedBytes = data.enumerated().map { i, byte in
            byte ^ keyBytes[i % keyBytes.count]
        }

        return String(bytes: decodedBytes, encoding: .utf8)
    }
    
    public static func sanitize(_ string: String?) -> String? {
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
    
    public static func hostPageURL(from feedURLString: String) -> String {
        guard let host = URL(string: feedURLString)?.host() else { return String() }
        return "https://\(host)/"
    }
    
    public static func firstImage(from content: String?) -> String? {
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
    
    public static func icon(from iconString: String?, fromHostURL: String) -> String {
        guard let iconString else {
            return "https://icons.duckduckgo.com/ip3/\(fromHostURL).ico"
        }
        return iconString
    }
    
    public static func safeAuthors(from authors: [String?]) -> String {
        var authorsString = [String]()
        for author in authors {
            if var authorString = sanitize(author) {
                authorString = authorString.replacingOccurrences(of: "\n", with: "")
                authorsString.append(authorString)
            }
        }
        return authorsString.joined(separator: ", ")
    }

    
    public static func safeAuthors(from authors: String?...) -> String {
        return safeAuthors(from: authors)
    }
    
    public static func safeTitle(from title: String?) -> String? {
        return sanitize(title)
    }
    
    public static func safeContent(from content: String?) -> String? {
        return sanitize(content)
    }
}
