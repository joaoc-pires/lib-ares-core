//
//  FeedKit+AresCore.swift
//
//
//  Created by Joao Pires on 02/09/2023.
//

import Foundation
import FeedKit

// MARK: - Atom Feed
extension FeedKit.AtomFeed {
    func aresFeed(withID feedID: String) -> ARSCFeed {
        let result = ARSCFeed(
            id: feedID,
            title: self.title ?? String(),
            link: self.links?.first?.attributes?.href,
            subTitle: self.subtitle?.value,
            pubDate: self.updated,
            image: self.icon?.firstImageLink?.firstImageLink ?? "\(self.id ?? String())/favicon.ico",
            entries: (self.entries ?? []).map({ $0.aresItem(from: feedID) })
        )
        return result
    }
}

extension FeedKit.AtomFeedEntry {
    func aresItem(from publisherID: String) -> ARSCEntry {
        ARSCEntry(
            id: links?.first?.attributes?.href ?? String(),
            title: title?.replacingOccurrences(of: "\n", with: ""),
            author: authors?.authorsString,
            content: content?.value,
            contentType: content?.attributes?.type,
            publishedDate: published ?? updated,
            thumbnail: media?.mediaThumbnails?.first?.value ?? content?.value?.firstImageLink,
            updatedDate: updated ?? published,
            publisherID: publisherID
        )
    }
}

extension Array where Element: AtomFeedEntryAuthor {
    
    var authorsString: String {
        var result = String()
        for element in self {
            result += "\(element.name ?? String()), "
        }
        if !result.isEmpty {
            result = String(result.dropLast(2))
        }
        return result
    }
}

// MARK: - RSS Feed
extension FeedKit.RSSFeed {
    func aresFeed(withID feedID: String) -> ARSCFeed {
        let result = ARSCFeed(
            id: feedID,
            title: self.title ?? String(),
            link: self.link,
            subTitle: self.description,
            pubDate: self.pubDate,
            image: self.image?.url ?? "\(self.link ?? String())/favicon.ico",
            entries: (self.items ?? []).map({ $0.aresItem(from: feedID) })
        )
        return result
    }
}

extension FeedKit.RSSFeedItem {
    func aresItem(from publisherID: String) -> ARSCEntry {
        ARSCEntry(
            id: link ?? String(),
            title: title?.replacingOccurrences(of: "\n", with: ""),
            author: author ?? dublinCore?.dcCreator,
            content: content?.contentEncoded ?? description,
            contentType: self.dublinCore?.dcType,
            publishedDate: pubDate ?? dublinCore?.dcDate,
            thumbnail: media?.mediaThumbnails?.first?.value ?? content?.contentEncoded?.firstImageLink ?? description?.firstImageLink,
            updatedDate: pubDate,
            publisherID: publisherID
        )
    }
}

// MARK: - JSON Feed
extension FeedKit.JSONFeed {
    func aresFeed(withID feedID: String) -> ARSCFeed {
        let result = ARSCFeed(
            id: feedID,
            title: self.title ?? String(),
            link: self.feedUrl,
            subTitle: self.description,
            pubDate: nil,
            image: self.icon ?? "\(self.feedUrl ?? String())/favicon.ico",
            entries: (self.items ?? []).map({ $0.aresItem(from: feedID) })
        )
        return result
    }
}

extension FeedKit.JSONFeedItem {
    func aresItem(from publisherID: String) -> ARSCEntry {
        ARSCEntry(
            id: url ?? String(),
            title: title?.replacingOccurrences(of: "\n", with: ""),
            author: author?.name,
            content: contentHtml,
            contentType: self.contentHtml == nil ? "text" : "html",
            publishedDate: datePublished,
            thumbnail: image ?? contentHtml?.firstImageLink,
            updatedDate: datePublished,
            publisherID: publisherID
        )
    }
}
