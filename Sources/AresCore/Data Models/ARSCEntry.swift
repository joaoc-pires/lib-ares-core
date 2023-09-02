import Foundation

public struct ARSCEntry {
    
    /// The ID of the entry is the URL for the item in the publisher website
    let id: String
    
    /// URL for the item in the publisher website.
    var entryURL: String? { id }
    
    /// Entry title
    var title: String?
    
    /// String of author or authors separated by a comma
    var author: String?
    
    /// The content string.
    var content: String?
    
    /// Content Type. it's better to assume all content is HTML, but there's also a lot of publishers that just have plain text. Assuming all content type is HTML will allow the app to fail gracefully
    var contentType: String?
    
    /// The date the entry was published
    var publishedDate: Date?
    
    /// This will either be the Image provided in the feed if it exists, or heuristics of the first image in the feed (if so configured), otherwise it will be empty.
    var thumbnail: String?
    
    /// the date the entry was last updated
    var updatedDate: Date?
    
    /// The publisher ID, that can be used to reference the publisher if needed
    var publisherID: String
}
