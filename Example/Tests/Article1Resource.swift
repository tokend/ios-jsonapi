import Foundation
import DLJSONAPI

class Article1Resource: Resource {
    
    override class var resourceType: String {
        return "articles1"
    }
    
    override class var codingKeys: [String: String] {
        return [
            "descriptionText": "description"
        ]
    }
    
    var title: String? {
        get { return self.value(forKey: "title") as? String }
        set { self.setValue(newValue, forKey: "title") }
    }
    var descriptionText: String? {
        get { return self.value(forKey: "descriptionText") as? String }
        set { self.setValue(newValue, forKey: "descriptionText") }
    }
    var keywords: [String]? {
        get { return self.value(forKey: "keywords") as? [String] }
        set { self.setValue(newValue, forKey: "keywords") }
    }
    var coauthors: [Person1Resource]? {
        get { return self.value(forKey: "coauthors") as? [Person1Resource] }
        set { self.setValue(newValue, forKey: "coauthors") }
    }
    var author: Person1Resource? {
        get { return self.value(forKey: "author") as? Person1Resource }
        set { self.setValue(newValue, forKey: "author") }
    }
    var hint: String? // from custom meta field in resource `data`
    var customObject: [String: Any]? {
        get { return self.value(forKey: "customObject") as? [String: Any] }
        set { self.setValue(newValue, forKey: "customObject") }
    }
}

class Person1Resource: Resource {
    
    override class var resourceType: String {
        return "persons1"
    }
    
    var name: String? {
        get { return self.value(forKey: "name") as? String }
        set { self.setValue(newValue, forKey: "name") }
    }
    var age: NSNumber?
    var gender: String?
    var favoriteArticle: Article1Resource? {
        get { return self.value(forKey: "favoriteArticle") as? Article1Resource }
        set { self.setValue(newValue, forKey: "favoriteArticle") }
    }
}
