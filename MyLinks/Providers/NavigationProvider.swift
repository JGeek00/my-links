import Foundation
import SwiftUI

@MainActor
class NavigationProvider: ObservableObject {
    static let shared = NavigationProvider()
    
    @Published var search = NavigationPath()
    @Published var library = NavigationPath()
    @Published var dashboard = NavigationPath()
}
