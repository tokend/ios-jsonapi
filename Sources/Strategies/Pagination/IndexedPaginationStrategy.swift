import Foundation

public class IndexedPaginationStrategy: PaginationStrategy {
    
    public typealias PageModel = IndexedPageModel
    
    public var index: Int?
    public let limit: Int
    public let order: PaginationOrder
    
    public var currentPage: PageModel? {
        set { self.index = newValue?.index }
        get {
            guard let index = self.index else { return nil }
            return PageModel(
                index: index,
                limit: self.limit,
                order: self.order
            )
        }
    }
    
    public var lastPage: PageModel?
    
    // MARK: -
    
    public init(
        index: Int?,
        limit: Int,
        order: PaginationOrder
        ) {
        
        self.index = index
        self.limit = limit
        self.order = order
    }
    
    required public init?(
        links: Links,
        defaultLimit: Int = 10,
        defaultOrder: PaginationOrder = .descending
        ) {
        
        guard let currentPage = links.indexedCurrentPage(
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
            ) else {
                return nil
        }
        
        self.index = currentPage.index
        self.limit = currentPage.limit
        self.order = currentPage.order
        
        if let lastPage = links.indexedLastPage(
            defaultLimit: currentPage.limit,
            defaultOrder: defaultOrder
            ) {
            self.lastPage = lastPage
        }
    }
    
    // MARK: - PaginationStrategy
    
    public var firstPage: PageModel {
        return IndexedPageModel(
            index: 0,
            limit: self.limit,
            order: self.order
        )
    }
    
    public var prevPage: PageModel? {
        guard let currentPage = self.currentPage, currentPage.index > 0 else {
            return nil
        }
        
        let prevPageIndex = currentPage.index - 1
        let page = PageModel(
            index: prevPageIndex,
            limit: self.limit,
            order: self.order
        )
        
        return page
    }
    
    public var nextPage: PageModel? {
        guard let currentPage = self.currentPage else {
            return nil
        }
        
        if let lastPage = self.lastPage {
            guard currentPage.index < lastPage.index else {
                return nil
            }
        }
        
        let nextPageIndex = currentPage.index + 1
        let page = PageModel(
            index: nextPageIndex,
            limit: self.limit,
            order: self.order
        )
        
        return page
    }
    
    public func toStartPage() -> PageModel {
        let startPage = self.firstPage
        self.currentPage = nil
        
        return startPage
    }
    
    public func toNextPage() -> PageModel? {
        guard let nextPage = self.nextPage else {
            return nil
        }
        
        self.currentPage = nextPage
        
        return nextPage
    }
    
    public func lastPageReached() {
        self.lastPage = self.currentPage
    }
    
    public func getWholeRangePage(
        defaultLimit: Int = 100,
        maxLimit: Int = Int.max
        ) -> PageModel {
        
        let index: Int = 0
        let limit: Int
        
        let firstPage = self.firstPage
        if let lastPage = self.lastPage {
            let pageCount = lastPage.index - firstPage.index + 1
            limit = min(pageCount * firstPage.limit, maxLimit)
        } else {
            limit = defaultLimit
        }
        
        return PageModel(
            index: index,
            limit: limit,
            order: self.order
        )
    }
}

public struct IndexedPageModel: PageModelProtocol {
    
    // MARK: - Public properties
    
    public let index: Int
    public let limit: Int
    public let order: PaginationOrder
    
    // MARK: -
    
    public init(
        index: Int,
        limit: Int,
        order: PaginationOrder
        ) {
        
        self.index = index
        self.limit = limit
        self.order = order
    }
    
    // MARK: - PageModel
    
    public func urlQueryItems() -> [URLQueryItem] {
        let queryItems: [URLQueryItem] = [
            QueryItem(urlKey: .page(.number), value: "\(self.index)"),
            QueryItem(urlKey: .page(.limit), value: "\(self.limit)"),
            QueryItem(urlKey: .page(.order), value: self.order.rawValue)
            ].map({ $0.urlQueryItem })
        
        return queryItems
    }
}

extension Links {
    
    public static func indexedPageForLink(
        _ link: Link?,
        defaultLimit: Int,
        defaultOrder: PaginationOrder
        ) -> IndexedPageModel? {
        
        guard let link = link,
            let pageNumberQueryItem = link.pageNumberQueryItem,
            let indexString = pageNumberQueryItem.value,
            let index = Int(indexString) else {
                
                return nil
        }
        
        let limit: Int
        if let pageLimitQueryItem = link.pageLimitQueryItem,
            let limitString = pageLimitQueryItem.value,
            let limitValue = Int(limitString) {
            
            limit = limitValue
        } else {
            limit = defaultLimit
        }
        
        let order: PaginationOrder
        if let pageOrderQueryItem = link.pageOrderQueryItem,
            let orderString = pageOrderQueryItem.value,
            let orderValue = PaginationOrder(rawValue: orderString) {
            order = orderValue
        } else {
            order = defaultOrder
        }
        
        return IndexedPageModel(
            index: index,
            limit: limit,
            order: order
        )
    }
    
    public func indexedCurrentPage(
        defaultLimit: Int,
        defaultOrder: PaginationOrder
        ) -> IndexedPageModel? {
        
        return Links.indexedPageForLink(
            self.aSelf,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }
    
    public func indexedLastPage(
        defaultLimit: Int,
        defaultOrder: PaginationOrder
        ) -> IndexedPageModel? {
        
        return Links.indexedPageForLink(
            self.last,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }
}
