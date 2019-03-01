import Foundation

public class Document<DataType> {
    
    // MARK: - Public properties
    
    public internal(set) var data: DataType?
    public internal(set) var included: [[String: Any]]?
    public let jsonapi: [String: Any]?
    public let links: Links?
    public let meta: [String: Any]?
    
    // MARK: - Private properties
    
    let context: Context
    
    // MARK: -
    
    public init(
        context: Context,
        data: DataType?,
        included: [[String: Any]]?,
        jsonapi: [String: Any]?,
        links: [String: Any]?,
        meta: [String: Any]?
        ) {
        
        self.context = context
        self.data = data
        self.included = included
        self.jsonapi = jsonapi
        self.links = {
            guard
                let links = links,
                let data = try? JSONSerialization.data(withJSONObject: links, options: [])
                else {
                    return nil
            }
            
            return try? JSONDecoder().decode(Links.self, from: data)
        }()
        self.meta = meta
    }
}
