import Foundation

public protocol PaginationStrategy {
    
    associatedtype PageModel = PageModelProtocol
    
    var currentPage: PageModel? { get set }
    var firstPage: PageModel { get set }
    var prevPage: PageModel? { get set }
    var nextPage: PageModel? { get set }
    var lastPage: PageModel? { get set }
    
    init?(links: Links, defaultLimit: Int, defaultOrder: PaginationOrder)
    
    /// Should reset `currentPage` to `nil`.
    /// - Returns: Value of `firstPage`.
    func toStartPage() -> PageModel
    func lastPageReached()
}

public enum PaginationOrder: String {
    
    case ascending = "asc"
    case descending = "desc"
}

public protocol PageModelProtocol {
    
    func urlQueryItems() -> [URLQueryItem]
}
