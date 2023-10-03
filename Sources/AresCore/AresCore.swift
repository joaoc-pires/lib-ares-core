import Foundation
import SimpleNetwork
import FeedKit
import OSLog

final public class AresCore {
    
    private var settings: UserDefaults
    private var log: Logger
    
    public init(with defaultSettings: UserDefaults? = nil) {
        self.settings = defaultSettings ?? UserDefaults.standard
        self.log = Logger(subsystem: "SimpleNetwork", category: "NetworkService")
    }
    
    public func fetch(_ feedURL: String, completion: @escaping (Result<ARSCFeed, AresCoreError>) -> (Void)) {
        let request = Request(url: feedURL, settings: self.settings)
        let networkService = NetworkService()
        networkService.fire(request: request) { result in
            switch result {
                case .success(let data):
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
    
    public func fetch(_ feedURL: String) async throws -> ARSCFeed {
        try await withCheckedThrowingContinuation { continuation in
            fetch(feedURL) { result in
                switch result {
                    case .success(let feed): continuation.resume(returning: feed)
                    case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    
    private struct Request: NetworkRequest {
        var url: String
        var eTag: String? { UserDefaults.standard.string(forKey: kEtag) }
        var method: SimpleNetwork.HTTPMethod { .get }
        var sessionDelegate: (URLSessionTaskDelegate)?
        
        var kEtag: String { return "kEtag\(String(describing: self))" }
        var kData: String { return "kData\(String(describing: self))" }
        
        private var settings: UserDefaults
        
        init(url: String, sessionDelegate: URLSessionTaskDelegate? = nil, settings: UserDefaults) {
            self.url = url
            self.sessionDelegate = sessionDelegate
            self.settings = settings
        }

        func getETagDataIfAvailable(_ response: HTTPURLResponse, _ data: Data) -> Data? {
            if response.allHeaderFields.keys.contains("Etag"), let etagValue = response.allHeaderFields["Etag"] as? String {
                UserDefaults.standard.setValue(etagValue, forKey: kEtag)
            }
            if data.count == 0 {
                return UserDefaults.standard.data(forKey: kData)
            }
            UserDefaults.standard.setValue(data, forKey: kData)
            return data
        }
    }
}
