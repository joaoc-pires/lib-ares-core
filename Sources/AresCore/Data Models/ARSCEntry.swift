import Foundation

public struct ARSCEntry: Identifiable {
    
    /// The ID of the entry is the URL for the item in the publisher website
    public let id: String
    
    /// URL for the item in the publisher website.
    public var entryUrl: String
    
    /// Entry title
    public var title: String
    
    /// String of author or authors separated by a comma
    public var author: String
    
    /// The content string.
    public var content: String
    
    /// Content Type. it's better to assume all content is HTML, but there's also a lot of publishers that just have plain text. Assuming all content type is HTML will allow the app to fail gracefully
    public var contentType: String
    
    /// The date the entry was published
    public var pubDate: Date
    
    /// This will either be the Image provided in the feed if it exists, or heuristics of the first image in the feed (if so configured), otherwise it will be empty.
    public var thumbnail: String
        
    /// The publisher ID, that can be used to reference the publisher if needed
    public var publisherId: String
    
    /// Public initializer for ARSCEntry
    public init(
    id: String,
    entryUrl: String,
    title: String,
    author: String,
    content: String,
    contentType: String,
    pubDate: Date,
    thumbnail: String,
    updatedDate: Date,
    publisherId: String) {
        self.id = id
        self.entryUrl = entryUrl
        self.title = title
        self.author = author
        self.content = content
        self.contentType = contentType
        self.pubDate = pubDate
        self.thumbnail = thumbnail
        self.publisherId = publisherId
    }
}
