import Foundation
import XCTest

@testable import DLJSONAPI

class IndexedPaginationStrategyTests: XCTestCase {
    
    let resourcePool = ResourcePool(
        queue: DispatchQueue(label: "test.queue", attributes: .concurrent)
    )
    
    override func setUp() {
        super.setUp()
        
        Context.registerClass(Article1Resource.self)
        Context.registerClass(Person1Resource.self)
    }
    
    func testDeserializeLinks() {
        let data = Data(jsonFileName: "Links")
        
        let document: Document<[Article1Resource]>
        do {
            document = try Deserializer.Collection(resourcePool: self.resourcePool).deserialize(data: data)
        } catch let error {
            XCTAssert(false, "Article collection deserialize error: \(error.localizedDescription)")
            return
        }
        
        guard let links = document.links else {
            XCTAssert(false, "Links deserialize: empty links")
            return
        }
        
        let defaultLimit = 100
        guard let paginationStrategy = IndexedPaginationStrategy(
            links: links,
            defaultLimit: defaultLimit
            ) else {
                XCTAssert(false, "Failed to init IndexedPaginationStrategy")
                return
        }
        
        guard let currentPage = paginationStrategy.currentPage else {
            XCTAssert(false, "Current page is empty")
            return
        }
        
        XCTAssert(
            currentPage.index == 0,
            "IndexedPaginationStrategy current page index is wrong. Has (\(currentPage.index)), but expected (\(0))."
        )
        XCTAssert(
            currentPage.limit == 15,
            "IndexedPaginationStrategy current page limit is wrong. Has (\(currentPage.limit)), but expected (\(15))."
        )
        
        guard let nextPage = paginationStrategy.toNextPage() else {
            XCTAssert(false, "Failed to get next page")
            return
        }
        
        XCTAssert(
            nextPage.index == 1,
            "IndexedPaginationStrategy next page index is wrong. Has (\(nextPage.index)), but expected (\(1))."
        )
        
        if let lastPage = paginationStrategy.toNextPage() {
            XCTAssert(
                false,
                "IndexedPaginationStrategy last page should be with index (\(1)). Has (\(lastPage.index))."
            )
            return
        }
        
        let wholeRangePage = paginationStrategy.getWholeRangePage(defaultLimit: 100, maxLimit: Int.max)
        XCTAssert(
            wholeRangePage.index == 0,
            "IndexedPaginationStrategy whole range page index is wrong. Has (\(wholeRangePage.index)), but expected (\(0))."
        )
        XCTAssert(
            wholeRangePage.limit == 30,
            "IndexedPaginationStrategy whole range page limit is wrong. Has (\(wholeRangePage.limit)), but expected (\(30))."
        )
        
        XCTAssert(true)
    }
}
