import Foundation

public struct ARSCEntry: Identifiable {
    
    /// The ID of the entry is the URL for the item in the publisher website
    public let id: String
    
    /// URL for the item in the publisher website.
    public var entryURL: String? { id }
    
    /// Entry title
    public var title: String?
    
    /// String of author or authors separated by a comma
    public var author: String?
    
    /// The content string.
    public var content: String?
    
    /// Content Type. it's better to assume all content is HTML, but there's also a lot of publishers that just have plain text. Assuming all content type is HTML will allow the app to fail gracefully
    public var contentType: String?
    
    /// The date the entry was published
    public var publishedDate: Date?
    
    /// This will either be the Image provided in the feed if it exists, or heuristics of the first image in the feed (if so configured), otherwise it will be empty.
    public var thumbnail: String?
    
    /// the date the entry was last updated
    public var updatedDate: Date?
    
    /// The publisher ID, that can be used to reference the publisher if needed
    public var publisherID: String
    
    /// Public initializer for ARSCEntry
    public init(
    id: String,
    title: String? = nil,
    author: String? = nil,
    content: String? = nil,
    contentType: String? = nil,
    publishedDate: Date? = nil,
    thumbnail: String? = nil,
    updatedDate: Date? = nil,
    publisherID: String) {
        self.id = id
        self.title = title
        self.author = author
        self.content = content
        self.contentType = contentType
        self.publishedDate = publishedDate
        self.thumbnail = thumbnail
        self.updatedDate = updatedDate
        self.publisherID = publisherID
    }
}
