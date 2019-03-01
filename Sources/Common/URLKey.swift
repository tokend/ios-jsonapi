import Foundation

public enum URLKey {
    
    // MARK: -
    
    case page(_ attribute: PageAttribute)
}

extension URLKey: Equatable {
    
    public static func == (left: URLKey, right: String) -> Bool {
        return left.description == right
    }
    
    public static func == (left: String, right: URLKey) -> Bool {
        return left == right.description
    }
}

extension URLKey {
    
    public enum PageAttribute: String {
        
        case number
        case limit
        case order
    }
}

extension URLKey: CustomStringConvertible {
    
    // MARK: - Public properties
    
    public var description: String {
        switch self {
            
        case .page(let attribute): return "page[\(attribute.rawValue)]"
        }
    }
}
