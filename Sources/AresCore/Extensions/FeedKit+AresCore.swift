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
    func aresFeed(url feedUrl: String) -> ARSCFeed {

        let hostUrl = Heuristics.hostPageURL(from: feedUrl)
        let safeTitle = Heuristics.safeTitle(from: self.title) ?? String()
        let icon = Heuristics.icon(
            from: self.icon?.firstImageLink?.firstImageLink,
            fromHostURL: hostUrl
        )
        let id = Heuristics.generateStableID(from: safeTitle, url: feedUrl)
        let result = ARSCFeed(
            id: id,
            feedUrl: feedUrl,
            title:  safeTitle,
            hostUrl: hostUrl,
            subTitle: self.subtitle?.value ?? String(),
            pubDate: self.updated ?? Date(),
            icon: icon,
            entries: (self.entries ?? []).map({ $0.aresItem(from: id) })
        )
        return result
    }
}

extension FeedKit.AtomFeedEntry {
    func aresItem(from publisherId: String) -> ARSCEntry {
        let safeTitle = Heuristics.safeTitle(from: self.title) ?? String()
        let safeUrl = links?.first?.attributes?.href ?? String()
        let listOfAuthors = self.authors?.map({$0.name ?? String()}) ?? []
        let safeAuthors = Heuristics.safeAuthors(from: listOfAuthors)
        
        let safeContent = Heuristics.safeContent(from: content?.value) ?? String()
        let safeThumbnail = media?.mediaThumbnails?.first?.value ?? Heuristics.firstImage(from: safeContent) ?? String()
        
        
        let id = Heuristics.generateStableID(from: safeTitle, url: safeUrl)
        
        return ARSCEntry(
            id: id,
            entryUrl: safeUrl,
            title: safeTitle,
            author: safeAuthors,
            content: safeContent,
            contentType: content?.attributes?.type ?? String(),
            pubDate: published ?? updated ?? Date(),
            thumbnail: safeThumbnail,
            updatedDate: updated ?? published ?? Date(),
            publisherId: publisherId
        )
    }
}

// MARK: - RSS Feed
extension FeedKit.RSSFeed {
    func aresFeed(url feedUrl: String) -> ARSCFeed {
        let safeTitle = self.title ?? String()
        let hostUrl = Heuristics.hostPageURL(from: feedUrl)
        let icon = Heuristics.icon(
            from: self.image?.url,
            fromHostURL: hostUrl
        )
        
        let id = Heuristics.generateStableID(from: safeTitle, url: feedUrl)
        
        let result = ARSCFeed(
            id: id,
            feedUrl: feedUrl,
            title: safeTitle,
            hostUrl: hostUrl,
            subTitle: self.description ?? String(),
            pubDate: self.pubDate ?? Date(),
            icon: icon,
            entries: (self.items ?? []).map({ $0.aresItem(from: id) })
        )
        return result
    }
}

extension FeedKit.RSSFeedItem {
    func aresItem(from publisherId: String) -> ARSCEntry {
        let safeTitle = Heuristics.safeTitle(from: self.title) ?? String()
        let safeUrl = self.link ?? String()
        
        let listOfAuthors = (self.author ?? self.dublinCore?.dcCreator)
        let safeAuthors = Heuristics.safeAuthors(from: listOfAuthors)
        
        let safeContent = Heuristics.safeContent(from: content?.contentEncoded ?? description)
        
        let possibleThumbnail1 = Heuristics.firstImage(from: media?.mediaThumbnails?.first?.value)
        let possibleThumbnail2 = Heuristics.firstImage(from: content?.contentEncoded)
        let possibleThumbnail3 = Heuristics.firstImage(from: description)
        let safeThumbnail = (possibleThumbnail1 ?? possibleThumbnail2 ?? possibleThumbnail3)
        
        let id = Heuristics.generateStableID(from: safeTitle, url: safeUrl)
        
        return ARSCEntry(
            id: id,
            entryUrl: safeUrl,
            title: safeTitle,
            author: safeAuthors,
            content: safeContent ?? String(),
            contentType: self.dublinCore?.dcType ?? String(),
            pubDate: pubDate ?? dublinCore?.dcDate ?? Date(),
            thumbnail: safeThumbnail ?? String(),
            updatedDate: pubDate ?? Date(),
            publisherId: publisherId
        )
    }
}

// MARK: - JSON Feed
extension FeedKit.JSONFeed {
    func aresFeed(url feedUrl: String) -> ARSCFeed {
        let safeTitle = self.title ?? String()
        let hostUrl = Heuristics.hostPageURL(from: feedUrl)
        let icon = Heuristics.icon(
            from: self.icon,
            fromHostURL: hostUrl
        )
        
        let id = Heuristics.generateStableID(from: safeTitle, url: feedUrl)
        
        let result = ARSCFeed(
            id: id,
            feedUrl: feedUrl,
            title: safeTitle,
            hostUrl: hostUrl,
            subTitle: self.description ?? String(),
            pubDate: Date(),
            icon: icon,
            entries: (self.items ?? []).map({ $0.aresItem(from: id) })
        )
        return result
    }
}

extension FeedKit.JSONFeedItem {
    func aresItem(from publisherId: String) -> ARSCEntry {
        let safeTitle = Heuristics.safeTitle(from: self.title) ?? String()
        let safeUrl = self.url ?? String()
        let safeAuthors = Heuristics.safeAuthors(from: author?.name)
        
        let safeContent = Heuristics.safeContent(from: contentHtml) ?? String()
        let safeThumbnail = image ?? Heuristics.firstImage(from: contentHtml?.firstImageLink)
        
        let id = Heuristics.generateStableID(from: safeTitle, url: safeUrl)
        
        return ARSCEntry(
            id: id,
            entryUrl: safeUrl,
            title: safeTitle,
            author: safeAuthors,
            content: safeContent,
            contentType: self.contentHtml == nil ? "text" : "html",
            pubDate: datePublished ?? Date(),
            thumbnail: safeThumbnail ?? String(),
            updatedDate: datePublished ?? Date(),
            publisherId: publisherId
        )
    }
}
