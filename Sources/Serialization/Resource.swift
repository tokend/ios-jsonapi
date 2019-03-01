import Foundation

open class Resource {
    
    // MARK: - Public properties
    
    public var id: String?
    
    open class var resourceType: String {
        fatalError("Must override `static var resourceType: String`")
    }
    
    open class var codingKeys: [String: String] {
        return [:]
    }
    
    public lazy var type: String = Swift.type(of: self).resourceType
    
    public var meta: NSMutableDictionary? {
        var aMeta: NSMutableDictionary?
        
        context?.queue.sync {
            aMeta = object?["meta"] as? NSMutableDictionary
        }
        
        return aMeta
    }
    
    public var attributes: NSMutableDictionary? {
        var anAttributes: NSMutableDictionary?
        
        context?.queue.sync {
            anAttributes = object?["attributes"] as? NSMutableDictionary
        }
        
        return anAttributes
    }
    
    public var relationships: NSMutableDictionary? {
        var aRelationships: NSMutableDictionary?
        
        context?.queue.sync {
            aRelationships = object?["relationships"] as? NSMutableDictionary
        }
        
        return aRelationships
    }
    
    // MARK: - Private properties
    
    let internalIdentifier = "<Resource_\(UUID().uuidString)>"
    
    private var resourceContext: Context?
    private var resourceObject: NSMutableDictionary?
    var context: Context?
    var object: NSMutableDictionary?
    
    // MARK: -
    
    public required init(context: Context? = nil) {
        guard let context = context else {
            let queue = DispatchQueue(label: "vox.context.queue", attributes: .concurrent)
            let resourcePool = ResourcePool(queue: queue)
            
            let aContext = Context(
                dictionary: NSMutableDictionary(),
                resourcePool: resourcePool
            )
            
            let anObject = NSMutableDictionary()
            self.resourceContext = aContext
            self.resourceObject = anObject
            self.context = aContext
            self.object = anObject
            
            return
        }
        
        self.context = context
    }
    
    // MARK: - Public
    
    open func value(forKey key: String) -> Any? {
        let key = Swift.type(of: self).codingKeys[key] ?? key
        
        return self.context?.value(forKey: key, inResource: self)
    }
    
    open func setValue(_ value: Any?, forKey key: String) {
        let key = Swift.type(of: self).codingKeys[key] ?? key
        
        self.context?.setValue(value, forKey: key, inResource: self)
    }
    
    public func documentDictionary() throws -> [String: Any] {
        let attributes = self.attributes
        let relationships = self.relationships
        
        var dictionary: [String: Any] = [
            "type": self.type
        ]
        
        if let id = self.id {
            dictionary["id"] = id
        }
        
        if let attributes = attributes,
            attributes.count > 0 {
            dictionary["attributes"] = attributes
        }
        
        if let relationships = relationships,
            relationships.count > 0 {
            dictionary["relationships"] = relationships
        }
        
        return ["data": dictionary]
    }
    
    public func documentData() throws -> Data {
        let data = try JSONSerialization.data(
            withJSONObject: self.documentDictionary(),
            options: []
        )
        
        return data
    }
}

extension Resource {
    
    subscript(key: String) -> Any? {
        get { return self.value(forKey: key) }
        set { self.setValue(newValue, forKey: key) }
    }
}

extension Resource: Equatable {
    
    static public func ==(left: Resource, right: Resource) -> Bool {
        return left.id == right.id
    }
}

extension Array where Element: Resource {
    
    public func documentDictionary() throws -> [String: Any] {
        let array = try map { (resource) throws -> [String: Any] in
            guard let id = resource.id else {
                throw JSONAPIError.serialization
            }
            
            let attributes = resource.attributes
            let relationships = resource.relationships
            
            var dictionary: [String: Any] = [
                "id": id,
                "type": resource.type
            ]
            
            if let attributes = attributes,
                attributes.count > 0 {
                dictionary["attributes"] = attributes
            }
            
            if let relationships = relationships,
                relationships.count > 0 {
                dictionary["relationships"] = relationships
            }
            
            return dictionary
        }
        
        return ["data": array]
    }
    
    public func documentData() throws -> Data {
        let data = try JSONSerialization.data(
            withJSONObject: self.documentDictionary(),
            options: []
        )
        
        return data
    }
}
