import Foundation

fileprivate class FakeClass {}

extension Data {
    init(jsonFileName: String) {
        let path = Bundle(for: FakeClass.self).url(forResource: jsonFileName, withExtension: "json")!
        
        self = try! Data(contentsOf: path)
    }
}
