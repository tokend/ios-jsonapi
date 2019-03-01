import Foundation
import XCTest
@testable import DLJSONAPI

@testable import DLJSONAPI

class LinksTests: XCTestCase {
    
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
        
        guard let selfLink = links.aSelf else {
            XCTAssert(false, "Links deserialize: `self` empty")
            return
        }
        
        guard let nextLink = links.next else {
            XCTAssert(false, "Links deserialize: `next` empty")
            return
        }
        
        XCTAssert(selfLink.endpoint == "/v2/resource", "Links deserialize: `self.endpoint` empty")
        XCTAssert(nextLink.endpoint == "/v2/resource", "Links deserialize: `next.endpoint` empty")
        
        guard let queryItem = nextLink.pageLimitQueryItem else {
            XCTAssert(false, "Links deserialize: `pageLimitQueryItem` empty")
            return
        }
        
        XCTAssert(
            queryItem.name == "page[limit]",
            "Links deserialize: `next.queryItems[1].name` wrong: (\(queryItem.name))"
        )
        XCTAssert(
            queryItem.value == "15",
            "Links deserialize: `next.queryItems[1].value` wrong: (\(String(describing: queryItem.value)))"
        )
        
        XCTAssert(true)
    }
}
