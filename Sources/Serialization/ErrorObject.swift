import Foundation

final public class ErrorObject {
    
    // MARK: - Public properties
    
    public let code: String?
    public let detail: String?
    public let id: String?
    public let links: [String: Any]?
    public let meta: Meta?
    public let source: Source?
    public let status: String?
    public let title: String?
    
    // MARK: -
    
    public init(dictionary: [String: Any]) {
        self.code = dictionary["code"] as? String
        self.detail = dictionary["detail"] as? String
        self.id = dictionary["id"] as? String
        self.links = dictionary["links"] as? [String: Any]
        self.meta = Meta(dictionary: dictionary["meta"] as? [String: Any])
        self.source = Source(dictionary: dictionary["source"] as? [String: Any])
        self.status = dictionary["status"] as? String
        self.title = dictionary["title"] as? String
    }
}

extension ErrorObject {
    
    final public class Source {
        
        // MARK: - Public properties
        
        public let dictionary: [String: Any]
        
        public let pointer: String?
        public let parameter: String?
        
        // MARK: -
        
        public init?(dictionary: [String: Any]?) {
            guard let dictionary = dictionary else { return nil }
            
            self.dictionary = dictionary
            
            self.pointer = dictionary["pointer"] as? String
            self.parameter = dictionary["parameter"] as? String
        }
    }
}

extension ErrorObject {
    
    final public class Meta {
        
        // MARK: - Public properties
        
        public let dictionary: [String: Any]
        
        public let error: String?
        public let field: String?
        
        // MARK: -
        
        public init?(dictionary: [String: Any]?) {
            guard let dictionary = dictionary else { return nil }
            
            self.dictionary = dictionary
            
            self.error = dictionary["error"] as? String
            self.field = dictionary["field"] as? String
        }
    }
}

extension ErrorObject: Swift.Error, LocalizedError {
    
    public var errorDescription: String? {
        var description: String = ""
        
        if let title = self.title {
            description += title
        }
        
        if let status = self.status {
            description += "(\(status))"
        }
        
        let checkDescriptionLength = {
            if description.count > 0 {
                description += ": "
            } else {
                description += "Error: "
            }
        }
        
        if let detail = self.detail {
            checkDescriptionLength()
            
            description += detail
        } else if let metaErrorDescription = self.getErrorDescriptionFromMeta() {
            checkDescriptionLength()
            
            description += metaErrorDescription
        }
        
        if description.isEmpty {
            description = "Unrecognized error."
        }
        
        return description
    }
}

extension ErrorObject {
    
    public func getErrorDescriptionFromMeta() -> String? {
        guard let meta = self.meta else { return nil }
        
        guard let error = meta.error else { return nil }
        
        var description = error
        
        if let field = meta.field {
            description += "(\(field))"
        }
        
        return description
    }
}
