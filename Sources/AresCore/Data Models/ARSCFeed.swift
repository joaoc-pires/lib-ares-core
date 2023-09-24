import Foundation

/// This Object is the container of the feed. If contains all the publisher info and the published items/entries on the feed
public struct ARSCFeed {
    
    /// The ID is the Syndication URL.
    public let id: String
    
    /// Syndication URL used to retrieve the data for the feed.
    public var feedURL: String? { id }
    
    /// Publication name
    public let title: String?
    
    /// Publication URL homepage. If not provided by the feed, it will be filled using FeedURL heuristics, and kept empty if it fails.
    public let link: String?
    
    /// Some publications use this field for tag lines.
    public let subTitle: String?
    
    /// Contains the date the feed was last published.
    public let pubDate: Date?
    
    /// Contains the publisher logo is available. If the logo is unavailable it will contain heuristics to try and get it, or stay empty if it fails
    public let image: String?
    
    /// contains all of the feed entries
    public let entries: [ARSCEntry]
}
