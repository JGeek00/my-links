import Foundation

struct CollectionOrTagLinksRequest: Hashable, Equatable {    
    let name: String
    let tagId: Int?
    let collectionId: Int?
    
    init(name: String, tagId: Int?, collectionId: Int?) {
        self.name = name
        self.tagId = tagId
        self.collectionId = collectionId
    }
}
