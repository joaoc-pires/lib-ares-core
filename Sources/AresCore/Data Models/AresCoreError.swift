import Foundation
import SimpleNetwork
import FeedKit

public enum AresCoreError: Error {
    case networkError(NetworkError)
    case parsingError(ParserError)
    case cachedReply
    case mockError
}
