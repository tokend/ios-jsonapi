import Foundation

public class JSONAPIDecoder {
    
    // MARK: - Internal
    
    public static func decode<DataType>(
        data: Data,
        resourcePool: ResourcePool
        ) throws -> Document<DataType> {
        
        guard let jsonObjectData = try JSONSerialization.jsonObject(
            with: data,
            options: [.mutableContainers]
            ) as? NSMutableDictionary else {
                throw JSONAPIError.serialization
        }
        
        guard let jsonObject = self.convertKeysToCamelCase(jsonObjectData) as? NSMutableDictionary else {
            throw JSONAPIError.serialization
        }
        
        // precheck if error
        
        let meta     = jsonObject["meta"] as? [String: Any]
        let jsonApi  = jsonObject["jsonApi"] as? [String: Any]
        let links    = jsonObject["links"] as? [String: Any]
        let included = jsonObject["included"] as? [[String: Any]]
        
        let context = Context(
            dictionary: jsonObject,
            resourcePool: resourcePool
        )
        
        let dataType = context.dataType()
        
        switch dataType {
            
        case .resource(let resource):
            return Document<DataType>(
                context: context,
                data: resource as? DataType,
                included: included,
                jsonapi: jsonApi,
                links: links,
                meta: meta
            )
            
        case .collection(let collection):
            return Document<DataType>(
                context: context,
                data: collection as? DataType,
                included: included,
                jsonapi: jsonApi,
                links: links,
                meta: meta
            )
            
        case .error(let errors):
            throw JSONAPIError.errors(errors)
            
        case .unknown:
            throw JSONAPIError.serialization
        }
    }
    
    public static func convertKeysToCamelCase(_ jsonObject: Any) -> Any {
        if let dict = jsonObject as? NSMutableDictionary {
            let newDict = NSMutableDictionary()
            dict.forEach { (key, value) in
                if let strKey = key as? String {
                    newDict[self.convertKeyToCamelCase(strKey)] = self.convertKeysToCamelCase(value)
                } else {
                    newDict[key] = self.convertKeysToCamelCase(value)
                }
            }
            return newDict
        } else if let array = jsonObject as? NSMutableArray {
            let newArray = NSMutableArray()
            array.forEach { (obj) in
                newArray.add(self.convertKeysToCamelCase(obj))
            }
            return newArray
        } else {
            return jsonObject
        }
    }
    
    public static func convertKeyToCamelCase(_ key: String) -> String {
        var words = key.components(separatedBy: "_")
        guard words.count > 1 else {
            return key
        }
        
        words = words.map({ (word) -> String in
            return word.capitalized
        })
        words[0] = words[0].lowercased()
        
        let result = words.joined()
        
        return result
    }
}
