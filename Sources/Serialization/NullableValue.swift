import Foundation

public enum NullableConstants {
    public static let nullString: String = UUID().uuidString
    public static let nullNumber: NSNumber = NSNumber(value: INT_MAX)
    public static let nullDictionary: [String: Any] = [.null: NSNull()]
    public static let nullStringArray: [String] = [.null]
    public static let nullNumberArray: [NSNumber] = [.null]
    public static let nullDictionaryArray: [[String: Any]] = [.null]
}

public protocol NullableAware {
    var isNull: Bool { get }
}

extension String: NullableAware {
    public var isNull: Bool {
        return self == NullableConstants.nullString
    }
    
    public static var null: String {
        return NullableConstants.nullString
    }
}

public extension Array where Element == String {
    var isNull: Bool {
        return self.first == .null
    }
    
    static var null: [Element] {
        return NullableConstants.nullStringArray
    }
}

public extension Dictionary where Key == String, Value: Any {
    static var null: [String: Any] {
        return NullableConstants.nullDictionary
    }
    
    var isNull: Bool {
        return self[.null] is NSNull
    }
}

public extension Array where Element == [String: Any] {
    static var null: [Element] {
        return NullableConstants.nullDictionaryArray
    }
    
    var isNull: Bool {
        return self.first?.isNull ?? false
    }
}

extension NSNumber: NullableAware {
    public var isNull: Bool {
        return self.isEqual(to: NullableConstants.nullNumber)
    }
    
    public static var null: NSNumber {
        return NullableConstants.nullNumber
    }
}

public extension Array where Element == NSNumber {
    static var null: [Element] {
        return NullableConstants.nullNumberArray
    }
    
    var isNull: Bool {
        return self.first?.isNull ?? false
    }
}

extension Resource: NullableAware {
    public var isNull: Bool {
        return self.id == .null
    }
    
    public static func null() -> Self {
        let aNull = self.init()
        aNull.id = .null
        
        return aNull
    }
}

public extension Array where Element: Resource {
    var isNull: Bool {
        return self.first?.id == .null
    }
    
    static var null: [Element] {
        return [.null()]
    }
}
