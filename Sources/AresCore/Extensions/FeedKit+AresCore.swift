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
    func aresFeed(withID feedId: String) -> ARSCFeed {
        let potentialUrl = self.links?.first?.attributes?.href ?? feedId
        let hostUrl = Heuristics.hostPageURL(from: potentialUrl)
        let icon = Heuristics.icon(
            from: self.icon?.firstImageLink?.firstImageLink,
            fromHostURL: hostUrl
        )
        let result = ARSCFeed(
            id: feedId,
            title:  Heuristics.safeTitle(from: self.title),
            hostUrl: hostUrl,
            subTitle: self.subtitle?.value,
            pubDate: self.updated,
            icon: icon,
            entries: (self.entries ?? []).map({ $0.aresItem(from: feedId) })
        )
        return result
    }
}

extension FeedKit.AtomFeedEntry {
    func aresItem(from publisherId: String) -> ARSCEntry {
        let safeTitle = Heuristics.safeTitle(from: self.title)
        
        let listOfAuthors = self.authors?.map({$0.name ?? String()}) ?? []
        let safeAuthors = Heuristics.safeAuthors(from: listOfAuthors)
        
        let safeContent = Heuristics.safeContent(from: content?.value)
        let safeThumbnail = media?.mediaThumbnails?.first?.value ?? Heuristics.firstImage(from: safeContent)
        
        return ARSCEntry(
            id: links?.first?.attributes?.href ?? String(),
            title: safeTitle,
            author: safeAuthors,
            content: safeContent,
            contentType: content?.attributes?.type,
            pubDate: published ?? updated,
            thumbnail: safeThumbnail,
            updatedDate: updated ?? published,
            publisherId: publisherId
        )
    }
}

// MARK: - RSS Feed
extension FeedKit.RSSFeed {
    func aresFeed(withID feedId: String) -> ARSCFeed {
        let potentialUrl = self.link ?? feedId
        let hostUrl = Heuristics.hostPageURL(from: potentialUrl)
        let icon = Heuristics.icon(
            from: self.image?.url,
            fromHostURL: hostUrl
        )
        let result = ARSCFeed(
            id: feedId,
            title: self.title ?? String(),
            hostUrl: hostUrl,
            subTitle: self.description,
            pubDate: self.pubDate,
            icon: icon,
            entries: (self.items ?? []).map({ $0.aresItem(from: feedId) })
        )
        return result
    }
}

extension FeedKit.RSSFeedItem {
    func aresItem(from publisherId: String) -> ARSCEntry {
        let safeTitle = Heuristics.safeTitle(from: self.title)
        
        let listOfAuthors = (self.author ?? self.dublinCore?.dcCreator)
        let safeAuthors = Heuristics.safeAuthors(from: listOfAuthors)
        
        let safeContent = Heuristics.safeContent(from: content?.contentEncoded ?? description)
        let possibleThumbnail1 = Heuristics.firstImage(from: media?.mediaThumbnails?.first?.value)
        let possibleThumbnail2 = Heuristics.firstImage(from: content?.contentEncoded)
        let possibleThumbnail3 = Heuristics.firstImage(from: description)

        let safeThumbnail = (possibleThumbnail1 ?? possibleThumbnail2 ?? possibleThumbnail3)
        
        return ARSCEntry(
            id: link ?? String(),
            title: safeTitle,
            author: safeAuthors,
            content: safeContent,
            contentType: self.dublinCore?.dcType,
            pubDate: pubDate ?? dublinCore?.dcDate,
            thumbnail: safeThumbnail,
            updatedDate: pubDate,
            publisherId: publisherId
        )
    }
}

// MARK: - JSON Feed
extension FeedKit.JSONFeed {
    func aresFeed(withID feedId: String) -> ARSCFeed {
        let potentialUrl = self.feedUrl ?? feedId
        let hostUrl = Heuristics.hostPageURL(from: potentialUrl)
        let icon = Heuristics.icon(
            from: self.icon,
            fromHostURL: hostUrl
        )
        let result = ARSCFeed(
            id: feedId,
            title: self.title ?? String(),
            hostUrl: hostUrl,
            subTitle: self.description,
            pubDate: nil,
            icon: icon,
            entries: (self.items ?? []).map({ $0.aresItem(from: feedId) })
        )
        return result
    }
}

extension FeedKit.JSONFeedItem {
    func aresItem(from publisherId: String) -> ARSCEntry {
        let safeTitle = Heuristics.safeTitle(from: self.title)
        
        let safeAuthors = Heuristics.safeAuthors(from: author?.name)
        
        let safeContent = Heuristics.safeContent(from: contentHtml)
        let safeThumbnail = image ?? Heuristics.firstImage(from: contentHtml?.firstImageLink)
        
        return ARSCEntry(
            id: url ?? String(),
            title: safeTitle,
            author: safeAuthors,
            content: safeContent,
            contentType: self.contentHtml == nil ? "text" : "html",
            pubDate: datePublished,
            thumbnail: safeThumbnail,
            updatedDate: datePublished,
            publisherId: publisherId
        )
    }
}
