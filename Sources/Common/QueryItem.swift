import Foundation

public struct QueryItem {
    
    // MARK: - Public properties
    
    public let name: String
    public let value: String?
    
    public let urlQueryItem: URLQueryItem
    
    // MARK: -
    
    public init(
        name: String,
        value: String?
        ) {
        
        self.name = name
        self.value = value
        
        self.urlQueryItem = URLQueryItem(
            name: name,
            value: value
        )
    }
    
    public init(
        urlKey: URLKey,
        value: String?
        ) {
        
        self.init(
            name: urlKey.description,
            value: value
        )
    }
}
