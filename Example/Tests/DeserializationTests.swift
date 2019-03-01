import Foundation
import XCTest

@testable import DLJSONAPI

class TokenDSDKTests: XCTestCase {
    
    let resourcePool = ResourcePool(
        queue: DispatchQueue(label: "test.queue", attributes: .concurrent)
    )
    
    override func setUp() {
        super.setUp()
        
        Context.registerClass(Article1Resource.self)
        Context.registerClass(Person1Resource.self)
    }
    
    func testDeserializeArticle1Single() {
        let data = Data(jsonFileName: "Article")
        
        let document: Document<Article1Resource>
        do {
            document = try Deserializer.Single(resourcePool: self.resourcePool).deserialize(data: data)
        } catch let error {
            XCTAssert(false, "Article single deserialize error: \(error.localizedDescription)")
            return
        }
        
        guard let resource = document.data else {
            XCTAssert(false, "Article single empty `data` error")
            return
        }
        
        if self.evaluateArticle(article: resource) {
            XCTAssert(true)
        }
    }
    
    func testDeserializeArticle1Collection() {
        let data = Data(jsonFileName: "Articles")
        
        let document: Document<[Article1Resource]>
        do {
            document = try Deserializer.Collection(resourcePool: self.resourcePool).deserialize(data: data)
        } catch let error {
            XCTAssert(false, "Article single deserialize error: \(error.localizedDescription)")
            return
        }
        
        guard let resource = document.data?.first else {
            XCTAssert(false, "Article single empty `data` error")
            return
        }
        
        if self.evaluateArticle(article: resource) {
            XCTAssert(true)
        }
    }
    
    func testDeserializeErrorWithSource() {
        let data = Data(jsonFileName: "ErrorsWithSource")
        
        var expectedErrors: [ErrorObject]?
        
        do {
            _ = try Deserializer.Single<MockClass>(resourcePool: self.resourcePool).deserialize(data: data)
        } catch JSONAPIError.errors(let errors) {
            expectedErrors = errors
        } catch {
            
        }
        
        XCTAssert(expectedErrors?.count == 1, "Wrong errors count: \(String(describing: expectedErrors?.count))")
        
        guard let errorObject = expectedErrors?.first else {
            XCTAssert(false, "No errors parsed")
            return
        }
        
        XCTAssert(errorObject.status == "422", "Wrong `status` value: \(String(describing: errorObject.status))")
        XCTAssert(errorObject.source?.pointer == "/data/attributes/first-name", "Wrong `source?.pointer` value: \(String(describing: errorObject.source?.pointer))")
        XCTAssert(errorObject.title == "Invalid Attribute", "Wrong `title` value: \(String(describing: errorObject.title))")
        XCTAssert(errorObject.detail == "First name must contain at least three characters.", "Wrong `detail` value: \(String(describing: errorObject.detail))")
    }
    
    func testDeserializeErrorWithMeta() {
        let data = Data(jsonFileName: "ErrorsWithMeta")
        
        let errorDescription: String
        
        do {
            _ = try Deserializer.Single<MockClass>(resourcePool: self.resourcePool).deserialize(data: data)
            XCTAssert(false, "Deserialize should throw.")
            
            return
        } catch let error {
            errorDescription = error.localizedDescription
        }
        
        let expectedResult = "Bad Request(400): Error description(id)\nBad Request(400): Error description(id)"
        XCTAssert(
            errorDescription == expectedResult,
            "Wrong error description '\(errorDescription)'. Expected '\(expectedResult)'."
        )
    }
    
    // MARK: -
    
    private func evaluateArticle(article: Article1Resource) -> Bool {
        do {
            let aValue = article.title
            guard let value = aValue, value == "Title" else {
                XCTAssert(false, "Article single empty/wrong `title` error: \(String(describing: aValue))")
                return false
            }
        }
        
        do {
            let aValue = article.descriptionText
            guard let value = aValue, value == "Desc" else {
                XCTAssert(false, "Article single empty/wrong `descriptionText` error: \(String(describing: aValue))")
                return false
            }
        }
        
        do {
            let aValue = article.keywords
            guard let value = aValue, value == ["key1", "key2"] else {
                XCTAssert(false, "Article single empty/wrong `keywords` error: \(String(describing: aValue))")
                return false
            }
        }
        
        do {
            let aValue = article.author
            guard let value = aValue, value.name == "Aron" else {
                XCTAssert(false, "Article single empty/wrong `author` error: \(String(describing: aValue))")
                return false
            }
        }
        
        do {
            let aValue = article.coauthors
            guard let value = aValue, value[1].name == "Debil" else {
                XCTAssert(false, "Article single empty/wrong `coauthors` error: \(String(describing: aValue))")
                return false
            }
        }
        
        return true
    }
}
