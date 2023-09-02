//
//  String+AresCore.swift
//
//
//  Created by Joao Pires on 02/09/2023.
//

import Foundation
import SwiftSoup

extension String {
    
    var firstImageLink: String? {
        guard let document: Document = try? SwiftSoup.parse(self) else { return nil }
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
