import Foundation

public enum JSONAPIError: Swift.Error, LocalizedError {
    
    case errors(_: [ErrorObject])
    case serialization
    
    // MARK: - Swift.Error
    
    public var errorDescription: String? {
        switch self {
            
        case .errors(let errors):
            return errors.map({ (error) -> String in
                return error.localizedDescription
            }).reduce("", { (result, string) in
                var newResult = result ?? ""
                if !newResult.isEmpty {
                    newResult += "\n"
                }
                newResult += string
                
                return newResult
            })
            
        case .serialization:
            return "Unrecognized response format."
        }
    }
}
