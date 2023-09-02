import Foundation

/// This Object is the container of the feed. If contains all the publisher info and the published items/entries on the feed
struct ARSCFeed {
    
    /// The ID is the Syndication URL.
    let id: String
    
    /// Syndication URL used to retrieve the data for the feed.
    var feedURL: String? { id }
    
    /// Publication name
    let title: String?
    
    /// Publication URL homepage. If not provided by the feed, it will be filled using FeedURL heuristics, and kept empty if it fails.
    let link: String?
    
    /// Some publications use this field for tag lines.
    let subTitle: String?
    
    /// Contains the date the feed was last published.
    let pubDate: Date?
    
    /// Contains the publisher logo is available. If the logo is unavailable it will contain heuristics to try and get it, or stay empty if it fails
    let image: String?
    
    /// contains all of the feed entries
    let entries: [ARSCEntry]
}
