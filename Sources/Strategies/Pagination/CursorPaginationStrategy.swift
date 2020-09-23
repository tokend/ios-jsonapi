import Foundation

public class CursorPaginationStrategy: PaginationStrategy {

    public typealias PageModel = CursorPageModel

    public var cursor: String?
    public let limit: Limit
    public let order: PaginationOrder

    public var currentPage: PageModel? {
        set { self.cursor = newValue?.cursor }
        get {
            guard let cursor = self.cursor else { return nil }
            return PageModel(
                cursor: cursor,
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
        cursor: String?,
        limit: Limit,
        order: PaginationOrder
        ) {

        self.cursor = cursor
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

        guard let currentPage = links.cursorCurrentPage(
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
            ) else {
                return nil
        }

        self.cursor = currentPage.cursor
        self.limit = currentPage.limit
        self.order = currentPage.order

        self.lastPage = links.cursorLastPage(
            defaultLimit: currentPage.limit,
            defaultOrder: defaultOrder
        )

        self.prevPage = links.cursorPrevPage(
            defaultLimit: currentPage.limit,
            defaultOrder: defaultOrder
        )

        self.nextPage = links.cursorNextPage(
            defaultLimit: currentPage.limit,
            defaultOrder: defaultOrder
        )

        self.firstPage = {
            if let firstPage = links.cursorFirstPage(
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

public struct CursorPageModel: PageModelProtocol {

    public static func defaultFirstPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
    ) -> CursorPageModel {

        CursorPageModel(
            cursor: nil,
            limit: defaultLimit,
            order: defaultOrder
        )
    }

    // MARK: - Public properties

    public let cursor: String?
    public let limit: PaginationStrategy.Limit
    public let order: PaginationOrder

    // MARK: -

    public init(
        cursor: String?,
        limit: PaginationStrategy.Limit,
        order: PaginationOrder
        ) {

        self.cursor = cursor
        self.limit = limit
        self.order = order
    }

    // MARK: - PageModel

    public func urlQueryItems() -> [URLQueryItem] {
        let queryItems: [URLQueryItem] = [
            QueryItem(urlKey: .page(.cursor), value: self.cursor),
            QueryItem(urlKey: .page(.limit), value: "\(self.limit)"),
            QueryItem(urlKey: .page(.order), value: self.order.rawValue)
            ].map({ $0.urlQueryItem })

        return queryItems
    }
}

extension Links {

    public static func cursorPageForLink(
        _ link: Link?,
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
        ) -> CursorPageModel? {

        guard let link = link,
            let pageCursorQueryItem = link.pageCursorQueryItem,
            let cursor = pageCursorQueryItem.value else {

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

        return CursorPageModel(
            cursor: cursor,
            limit: limit,
            order: order
        )
    }

    public func cursorCurrentPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
        ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.aSelf,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func cursorLastPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
        ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.last,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func cursorFirstPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
    ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.first,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func cursorNextPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
    ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.next,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func cursorPrevPage(
        defaultLimit: PaginationStrategy.Limit,
        defaultOrder: PaginationOrder
    ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.prev,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }
}
