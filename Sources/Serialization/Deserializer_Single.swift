import Foundation

extension Deserializer {
    
    public class Single<ResourceType: Resource> {
        
        // MARK: - Public properties
        
        public let resourcePool: ResourcePool
        
        // MARK: -
        
        public init(resourcePool: ResourcePool) {
            self.resourcePool = resourcePool
        }
        
        // MARK: - Public
        
        public func deserialize(data: Data) throws -> Document<ResourceType> {
            return try JSONAPIDecoder.decode(
                data: data,
                resourcePool: self.resourcePool
            )
        }
    }
}
