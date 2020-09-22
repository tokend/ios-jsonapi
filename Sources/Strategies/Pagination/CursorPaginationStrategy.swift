import Foundation

public class CursorPaginationStrategy: PaginationStrategy {

    public typealias PageModel = CursorPageModel

    public var cursor: String?
    public let limit: Int
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
        limit: Int,
        order: PaginationOrder
        ) {

        self.cursor = cursor
        self.limit = limit
        self.order = order
        self.firstPage = PageModel(
            cursor: nil,
            limit: self.limit,
            order: self.order
        )
    }

    required public init?(
        links: Links,
        defaultLimit: Int = 10,
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
                defaultOrder: defaultOrder
                ) {

                return firstPage

            } else {

                return PageModel(
                    cursor: nil,
                    limit: currentPage.limit,
                    order: currentPage.order
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

    // MARK: - Public properties

    public let cursor: String?
    public let limit: Int
    public let order: PaginationOrder

    // MARK: -

    public init(
        cursor: String?,
        limit: Int,
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
        defaultLimit: Int,
        defaultOrder: PaginationOrder
        ) -> CursorPageModel? {

        guard let link = link,
            let pageCursorQueryItem = link.pageCursorQueryItem,
            let cursor = pageCursorQueryItem.value else {

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

        return CursorPageModel(
            cursor: cursor,
            limit: limit,
            order: order
        )
    }

    public func cursorCurrentPage(
        defaultLimit: Int,
        defaultOrder: PaginationOrder
        ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.aSelf,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func cursorLastPage(
        defaultLimit: Int,
        defaultOrder: PaginationOrder
        ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.last,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func cursorFirstPage(
        defaultLimit: Int,
        defaultOrder: PaginationOrder
    ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.first,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func cursorNextPage(
        defaultLimit: Int,
        defaultOrder: PaginationOrder
    ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.next,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }

    public func cursorPrevPage(
        defaultLimit: Int,
        defaultOrder: PaginationOrder
    ) -> CursorPageModel? {

        return Links.cursorPageForLink(
            self.prev,
            defaultLimit: defaultLimit,
            defaultOrder: defaultOrder
        )
    }
}
