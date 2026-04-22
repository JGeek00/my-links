import Foundation
import SwiftUI

class Config {
    static let groupId = "group.com.jgeek00.MyLinks"
    static let sentryDsn = "https://82fc19e1568f44139a8938f25d207d0a@glitchtip.jgeek00.com/9"
    static let linkwardenCloudUrl = "https://cloud.linkwarden.app"
    static let defaultCollection = CollectionCreation(id: 1, name: "Unorganized", ownerId: 1)
    static let gridColumns = [GridItem(.adaptive(minimum: 400))]
    static let collectionsCountSelectorBreakpoint = 10
    static let selectedTagsCountLabelBreakpoint = 5
    static let searchViewMoreAmount = 10
}
