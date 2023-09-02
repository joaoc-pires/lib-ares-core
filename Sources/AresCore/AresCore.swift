import Foundation
import SimpleNetwork

class AresCore {
    
    private var settings: UserDefaults
    
    init(with defaultSettings: UserDefaults? = nil) {
        self.settings = defaultSettings ?? UserDefaults.standard
    }
    
    func fetch(_ feedURL: String) {
        let etag = self.settings.string(forKey: "Etag\(feedURL)") ?? String()
        
    }
    
}
