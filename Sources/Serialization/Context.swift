import Foundation

public class Context: NSObject {
    
    // MARK: - Public properties
    
    public let resourcePool: ResourcePool
    
    // MARK: - Private properties
    
    private static var classes: [String: Resource.Type] = [:]
    
    let dictionary: NSMutableDictionary
    
    var queue: DispatchQueue {
        return self.resourcePool.queue
    }
    
    // MARK: -
    
    public init(
        dictionary: NSMutableDictionary,
        resourcePool: ResourcePool
        ) {
        
        self.dictionary = dictionary
        self.resourcePool = resourcePool
    }
    
    // MARK: - Public
    
    public static func registerClass(_ resourceClass: Resource.Type) {
        self.classes[resourceClass.resourceType] = resourceClass
    }
    
    // MARK: - Internal
    
    func dataType() -> DataType {
        var dataType: DataType!
        
        self.queue.sync {
            if let array = self.dictionary["included"] as? NSMutableArray {
                array.forEach({ (resourceData) in
                    guard let dictionary = resourceData as? NSMutableDictionary else { fatalError("Invalid data type") }
                    self.mapResource(for: dictionary, overwrite: true)
                })
            }
            
            if let data = self.dictionary["data"] as? NSMutableDictionary {
                let resource = self.mapResource(for: data, overwrite: true)
                
                dataType = .resource(resource)
            } else if let data = self.dictionary["data"] as? NSMutableArray {
                let resources = data.compactMap({ (resourceData) -> Resource? in
                    guard let dictionary = resourceData as? NSMutableDictionary else {
                        fatalError("Invalid data type")
                    }
                    
                    let resource = self.mapResource(for: dictionary, overwrite: true)
                    
                    return resource
                })
                
                dataType = .collection(resources)
            } else if let errors = self.dictionary["errors"] as? NSMutableArray {
                let errorObjects = errors.compactMap({ (object) -> ErrorObject? in
                    guard let object = object as? [String: Any] else {
                        return nil
                    }
                    
                    return ErrorObject(dictionary: object)
                })
                
                dataType = .error(errorObjects)
            } else {
                dataType = .unknown
            }
        }
        
        return dataType
    }
    
    @discardableResult func mapResource(for data: NSMutableDictionary, overwrite: Bool) -> Resource? {
        guard let id = data["id"] as? String else {
            fatalError("Resource id must be defined")
        }
        
        guard let type = data["type"] as? String else {
            fatalError("Resource type must be defined")
        }
        
        guard let resourceClass = self.resourceClass(for: type) else {
            return nil
        }
        
        let resource = resourceClass.init(context: self)
        resource.id = id
        resource.type = type
        self.resourcePool.addResource(resource, overwrite: overwrite)
        resource.object = data
        
        if let relationships = data["relationships"] as? NSMutableDictionary {
            relationships.forEach { (_, value) in
                guard let relation = value as? NSMutableDictionary else {
                    fatalError("Invalid data type for relationships")
                }
                
                let data = relation["data"]
                
                if let single = data as? NSMutableDictionary {
                    self.mapResource(for: single, overwrite: false)
                } else if let collection = data as? [NSMutableDictionary] {
                    collection.forEach({ (value) in
                        self.mapResource(for: value, overwrite: false)
                    })
                } else {
                    fatalError("Invalid data type for relationships")
                }
            }
        }
        
        return resource
    }
    
    func resourceClass(for type: String) -> Resource.Type? {
        guard let resourceClass = Context.classes[type] else {
            return nil
        }
        
        return resourceClass
    }
}

internal enum DataType {
    case resource(Resource?)
    case collection([Resource]?)
    case error([ErrorObject])
    case unknown
}
