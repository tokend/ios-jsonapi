import Foundation

public protocol PaginationStrategy {
    
    associatedtype PageModel = PageModelProtocol
    
    var currentPage: PageModel? { get set }
    var firstPage: PageModel { get }
    var prevPage: PageModel? { get }
    var nextPage: PageModel? { get }
    var lastPage: PageModel? { get set }
    
    init?(links: Links, defaultLimit: Int, defaultOrder: PaginationOrder)
    
    /// Should reset `currentPage` to `nil`.
    /// - Returns: Value of `firstPage`.
    func toStartPage() -> PageModel
    func toNextPage() -> PageModel?
    func lastPageReached()
    
    func getWholeRangePage(defaultLimit: Int, maxLimit: Int) -> PageModel
}

public enum PaginationOrder: String {
    
    case ascending = "asc"
    case descending = "desc"
}

public protocol PageModelProtocol {
    
    func urlQueryItems() -> [URLQueryItem]
}
