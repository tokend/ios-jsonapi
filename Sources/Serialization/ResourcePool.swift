import Foundation

open class ResourcePool {
    
    // MARK: - Private properties
    
    public let queue: DispatchQueue
    private var resourceMap: [String: Resource]
    
    // MARK: -
    
    public init(queue: DispatchQueue) {
        self.queue = queue
        self.resourceMap = [:]
    }
    
    // MARK: - Public
    
    public func addResource(_ resource: Resource, overwrite: Bool) {
        self.queue.sync {
            if !overwrite {
                let key = self.keyForResource(resource)
                if self.resourceMap[key] != nil {
                    return
                }
            }
            
            let key = self.keyForResource(resource)
            self.resourceMap[key] = resource
        }
    }
    
    public func resource(forBasicObject basicObject: [String: String]) -> Resource? {
        var value: Resource?
        
        self.queue.sync {
            let key = self.keyForBasicObject(basicObject)
            value = self.resourceMap[key]
        }
        
        return value
    }
    
    public func keyForBasicObject(_ basicObject: [String: String]) -> String {
        return basicObject["id"]! + "_" + basicObject["type"]!
    }
    
    public func keyForResource(_ resource: Resource) -> String {
        return resource.id! + "_" + resource.type
    }
}
