//
//  String+AresCore.swift
//
//
//  Created by Joao Pires on 02/09/2023.
//

import Foundation
import SwiftSoup

extension String {
    
    var htmlDecoded: String {
        var result = self
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
            result = result.replacingOccurrences(of: entity, with: character)
        }
        return result
    }
    
    var firstImageLink: String? {
        guard let document: Document = try? SwiftSoup.parse(self.htmlDecoded) else { return nil }
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
    
}
