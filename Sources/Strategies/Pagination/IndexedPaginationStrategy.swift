import Foundation

public class IndexedPaginationStrategy: PaginationStrategy {
    
    public typealias PageModel = IndexedPageModel
    
    public var index: Int?
    public let limit: Limit
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

    public var firstPage: PageModel
    public var lastPage: PageModel?
    public var prevPage: PageModel?
    public var nextPage: PageModel?
    
    // MARK: -
    
    public init(
        index: Int?,
        limit: Limit,
        order: PaginationOrder
        ) {
        
        self.index = index
        self.limit = limit
        self.order = order
        self.firstPage = PageModel.defaultFirstPage(
            defaultLimit: limit,
            defaultOrder: order
        )
    }
    
    required public init?(
        links: Links,
        defaultLimit: Limit = 10,
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
        
        self.lastPage = links.indexedLastPage(
            defaultLimit: currentPage.limit,
            defaultOrder: defaultOrder
        )

        self.prevPage = links.indexedPrevPage(
            defaultLimit: currentPage.limit,
            defaultOrder: defaultOrder
        )

        self.nextPage = links.indexedNextPage(
            defaultLimit: currentPage.limit,
            defaultOrder: defaultOrder
        )

        self.firstPage = {
            if let firstPage = links.indexedFirstPage(
                defaultLimit: currentPage.limit,
                defaultOrder: currentPage.order
                ) {

                return firstPage

            } else {

                return PageModel.defaultFirstPage(
                    defaultLimit: currentPage.limit,
                    defaultOrder: currentPage.order
                )
            }
        }()
    }
    
    // MARK: - PaginationStrategy
    
    public func toStartPage() -> PageModel {
        let startPage = self.firstPage
        self.currentPage = nil
        
        return startPage
    }
    
    public func lastPageReached() {
        self.lastPage = self.currentPage
    }
}

public struct IndexedPageModel: PageModelProtocol {

    public static func defaultFirstPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
    ) -> IndexedPageModel {

        IndexedPageModel(
            index: 0,
            limit: defaultLimit,
            order: defaultOrder
        )
    }
    
    // MARK: - Public properties
    
    public let index: Int
    public let limit: PaginationStrategy.Limit
    public let order: PaginationOrder
    
    // MARK: -
    
    public init(
        index: Int,
        limit: PaginationStrategy.Limit,
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
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
        ) -> IndexedPageModel? {
        
        guard let link = link,
            let pageNumberQueryItem = link.pageNumberQueryItem,
            let indexString = pageNumberQueryItem.value,
            let index = Int(indexString) else {
                
                return nil
        }
        
        let limit: PaginationStrategy.Limit
        if let pageLimitQueryItem = link.pageLimitQueryItem,
            let limitString = pageLimitQueryItem.value,
            let limitValue = PaginationStrategy.Limit(limitString) {
            
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
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
        ) -> IndexedPageModel? {
        
        return Links.indexedPageForLink(
            self.aSelf,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }
    
    public func indexedLastPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
        ) -> IndexedPageModel? {
        
        return Links.indexedPageForLink(
            self.last,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func indexedFirstPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
    ) -> IndexedPageModel? {

        return Links.indexedPageForLink(
            self.first,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func indexedNextPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
    ) -> IndexedPageModel? {

        return Links.indexedPageForLink(
            self.next,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func indexedPrevPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
    ) -> IndexedPageModel? {

        return Links.indexedPageForLink(
            self.prev,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }
}
