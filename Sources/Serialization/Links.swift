import Foundation

public class Links: Decodable {
    
    // MARK: - Public properties
    
    public let aSelf: Link?
    public let first: Link?
    public let prev: Link?
    public let next: Link?
    public let last: Link?
    
    enum CodingKeys: String, CodingKey {
        case `self`
        case first
        case prev
        case next
        case last
    }
    
    // MARK: -
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let selfLink = try container.decodeIfPresent(String.self, forKey: CodingKeys.`self`)
        let firstLink = try container.decodeIfPresent(String.self, forKey: CodingKeys.first)
        let prevLink = try container.decodeIfPresent(String.self, forKey: CodingKeys.prev)
        let nextLink = try container.decodeIfPresent(String.self, forKey: CodingKeys.next)
        let lastLink = try container.decodeIfPresent(String.self, forKey: CodingKeys.last)
        
        self.aSelf = Link(escapedUrlString: selfLink)
        self.first = Link(escapedUrlString: firstLink)
        self.prev = Link(escapedUrlString: prevLink)
        self.next = Link(escapedUrlString: nextLink)
        self.last = Link(escapedUrlString: lastLink)
    }
}

public struct Link {
    
    // MARK: - Public properties
    
    public let stringUrl: String
    
    public let endpoint: String
    public let queryItems: [QueryItem]
    
    public var urlQueryItems: [URLQueryItem] {
        return self.queryItems.map({ $0.urlQueryItem })
    }
    
    public var pageNumberQueryItem: QueryItem? {
        return self.queryItemForURLKey(.page(.number))
    }

    public var pageCursorQueryItem: QueryItem? {
        return self.queryItemForURLKey(.page(.cursor))
    }
    
    public var pageLimitQueryItem: QueryItem? {
        return self.queryItemForURLKey(.page(.limit))
    }
    
    public var pageOrderQueryItem: QueryItem? {
        return self.queryItemForURLKey(.page(.order))
    }
    
    // MARK: -
    
    public init?(escapedUrlString: String?) {
        guard let escapedUrlString = escapedUrlString else { return nil }
        guard let urlString = escapedUrlString.removingPercentEncoding else { return nil }
        
        self.stringUrl = urlString
        
        let urlComponents = urlString.components(separatedBy: "?")
        guard urlComponents.count == 2 else { return nil }
        
        self.endpoint = urlComponents[0]
        
        let queryItemsComponents = urlComponents[1].components(separatedBy: "&")
        self.queryItems = queryItemsComponents.compactMap({ (component) -> QueryItem? in
            let components = component.components(separatedBy: "=")
            guard 1...2 ~= components.count else { return nil }
            
            let name = components[0]
            
            guard name.count > 0 else { return nil }
            
            let value: String?
            if components.count == 2 {
                value = components[1]
            } else {
                value = nil
            }
            
            let queryItem = QueryItem(
                name: name,
                value: value
            )
            
            return queryItem
        })
    }
    
    // MARK: - Public
    
    public func queryItemForName(_ name: String) -> QueryItem? {
        return self.queryItems.first(where: { $0.name == name })
    }
    
    public func queryItemForURLKey(_ urlKey: URLKey) -> QueryItem? {
        return self.queryItemForName(urlKey.description)
    }
}
