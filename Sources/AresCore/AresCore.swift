import Foundation
import SimpleNetwork
import FeedKit
import OSLog

public class AresCore {
    
    private var settings: UserDefaults
    private var log: Logger
    private var suppressLogs: Bool
    
    public init(with defaultSettings: UserDefaults? = nil, supressLogs: Bool = false) {
        self.settings = defaultSettings ?? UserDefaults.standard
        self.log = Logger(subsystem: "AresCore", category: "AresCoreService")
        self.suppressLogs = supressLogs
    }
    private enum LogMessageType {
        case info
        case error
        case debug
    }
    private func logMessage(_ message: String, _ type: LogMessageType) {
        guard !suppressLogs else { return }
        switch type {
            case .info: log.info("\(message)")
            case .error: log.error("\(message)")
            case .debug: log.debug("\(message)")
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
                            self.logMessage("parsed '\(data.count) bytes' from '\(feedURL)'", .info)
                            switch feed {
                                case let .atom(atomFeed):   completion(.success(atomFeed.aresFeed(url: feedURL)))
                                case let .rss(rssFeed):     completion(.success(rssFeed.aresFeed(url: feedURL)))
                                case let .json(jsonFeed):   completion(.success(jsonFeed.aresFeed(url: feedURL)))
                            }
                        case .failure(let error):
                            self.logMessage("failed to parse '\(data.count) bytes' from '\(feedURL)'", .error)
                            completion(.failure(.parsingError(error)))
                    }
                case .failure(let error): completion(.failure(.networkError(error)))
            }
        }
    }
    
    /// Starts an asynchronous download of a given feed URL
    /// - Parameter feedURL: the url of the feed to download
    /// - Returns: ARSCFeed object representing that feed, or throws any error in might have encountered when downloading and parsing
    public func fetch(_ feedURL: String, ignoreEtag: Bool = false) async throws(AresCoreError) -> ARSCFeed {
        let request = Request(url: feedURL, settings: self.settings)
        let networkService = NetworkService()
        let data: Data
        do {
            data = try await networkService.fire(request: request, ignoreEtag: ignoreEtag)
        }
        catch {
            throw .networkError(error)
        }
        guard !data.isEmpty else { throw .cachedReply }
        let parsedResult = FeedParser(data: data).parse()
        switch parsedResult {
            case .success(let feed):
                logMessage("parsed '\(data.count) bytes' from '\(feedURL)'", .info)
                switch feed {
                    case let .atom(atomFeed):   return atomFeed.aresFeed(url: feedURL)
                    case let .rss(rssFeed):     return rssFeed.aresFeed(url: feedURL)
                    case let .json(jsonFeed):   return jsonFeed.aresFeed(url: feedURL)
                }
            case .failure(let error):
                self.logMessage("failed to parse '\(data.count) bytes' from '\(feedURL)'", .error)
                throw .parsingError(error)
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
        public var eTag: String? { settings.string(forKey: kEtag) }
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
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(url)
        }
        
        public static func == (lhs: AresCore.Request, rhs: AresCore.Request) -> Bool {
            lhs.url == rhs.url
        }
    }
}
