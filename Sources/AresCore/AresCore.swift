import Foundation
import SimpleNetwork
import FeedKit
import OSLog

final public class AresCore {
    
    private var settings: UserDefaults
    private var log: Logger
    
    public init(with defaultSettings: UserDefaults? = nil) {
        self.settings = defaultSettings ?? UserDefaults.standard
        self.log = Logger(subsystem: "AresCore", category: "AresCoreService")
    }
    
    /// Starts the synchronous download of multiple feeds. The result will be published using NotificationCenter. Any object that wants to receive the **successful** results of these operations must listen to Notification.Name.feedFinishedDownload
    /// - Parameter feeds: A list of ARSCFeed
    public func fetch(_ feeds: [ARSCFeed], ignoreEtag: Bool = false) {
        fetch(feeds.map({ $0.id }), ignoreEtag: ignoreEtag)
    }
    
    /// Starts the synchronous download of multiple feeds. The result will be published using NotificationCenter. Any object that wants to receive the **successful** results of these operations must listen to Notification.Name.feedFinishedDownload
    /// - Parameter feeds: A list of URL strings
    public func fetch(_ feeds: [String], ignoreEtag: Bool = false) {
        for feed in feeds {
            fetch(feed, ignoreEtag: ignoreEtag) { result in
                switch result {
                    case .success(let newFeed): NotificationCenter.default.post(name: .feedFinishedDownload, object: newFeed)
                    case .failure(let error): self.log.error("failed to synchronously download '\(feed)' with error '\(error)', '\(error.localizedDescription)'")
                }
            }
        }
    }
    
    /// Starts a synchronous download of a given feed
    /// - Parameters:
    ///   - feedURL: the url of the feed to download
    ///   - completion: a closure that returns a Result type with either the feed, or the error it might have encountered when downloading and parsing
    public func fetch(_ feedURL: String, ignoreEtag: Bool = false, completion: @escaping (Result<ARSCFeed, AresCoreError>) -> (Void)) {
        let request = Request(url: feedURL, settings: self.settings)
        let networkService = NetworkService()
        networkService.fire(request: request, ignoreEtag: ignoreEtag) { result in
            switch result {
                case .success(let data):
                    guard !data.isEmpty else {
                        completion(.failure(.cachedReply))
                        return
                    }
                    let parsedResult = FeedParser(data: data).parse()
                    switch parsedResult {
                        case .success(let feed):
                            self.log.info("parsed '\(data.count) bytes' from '\(feedURL)'")
                            switch feed {
                                case let .atom(atomFeed):   completion(.success(atomFeed.aresFeed(withID: feedURL)))
                                case let .rss(rssFeed):     completion(.success(rssFeed.aresFeed(withID: feedURL)))
                                case let .json(jsonFeed):   completion(.success(jsonFeed.aresFeed(withID: feedURL)))
                            }
                        case .failure(let error):
                            self.log.error("failed to parse '\(data.count) bytes' from '\(feedURL)'")
                            completion(.failure(.parsingError(error)))
                    }
                case .failure(let error): completion(.failure(.networkError(error)))
            }
        }
    }
    
    /// Starts an asynchronous download of a given feed URL
    /// - Parameter feedURL: the url of the feed to download
    /// - Returns: ARSCFeed object representing that feed, or throws any error in might have encountered when downloading and parsing
    public func fetch(_ feedURL: String, ignoreEtag: Bool = false) async throws -> ARSCFeed {
        try await withCheckedThrowingContinuation { continuation in
            fetch(feedURL, ignoreEtag: ignoreEtag) { result in
                switch result {
                    case .success(let feed): continuation.resume(returning: feed)
                    case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    // Deletes the etag for a specific URL
    public func deleteCache(for feedURL: String) {
        let request = AresCore.Request(url: feedURL, settings: settings)
        let etagKey = request.kEtag
        settings.removeObject(forKey: etagKey)
    }
    
    // Deletes all the cached etags
    public func deleteCache() {
        for key in settings.dictionaryRepresentation().keys {
            settings.removeObject(forKey: key)
        }
    }
    
    public struct Request: NetworkRequest, Hashable {
        
        public var url: String
        public var eTag: String? { UserDefaults.standard.string(forKey: kEtag) }
        public var method: SimpleNetwork.HTTPMethod { .get }
        public var sessionDelegate: (URLSessionTaskDelegate)?
        
        public var kEtag: String { return "kEtag\(url)" }
        public var kData: String { return "kData\(url)" }
        
        private var settings: UserDefaults
        
        public init(url: String, sessionDelegate: URLSessionTaskDelegate? = nil, settings: UserDefaults) {
            self.url = url
            self.sessionDelegate = sessionDelegate
            self.settings = settings
        }

        public func getETagDataIfAvailable(_ response: HTTPURLResponse, _ data: Data) -> Data? {
            if response.allHeaderFields.keys.contains("Etag"), let etagValue = response.allHeaderFields["Etag"] as? String {
                UserDefaults.standard.setValue(etagValue, forKey: kEtag)
            }
            return nil
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(url)
        }
        
        public static func == (lhs: AresCore.Request, rhs: AresCore.Request) -> Bool {
            lhs.url == rhs.url
        }
    }
}
