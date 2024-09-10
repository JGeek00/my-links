import SwiftUI

struct AdvancedSettings: View {
    
    init() {}
    
    @AppStorage(StorageKeys.useOldTabBar, store: UserDefaults.shared) private var useOldTabBar: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                if #available(iOS 18, *) {
                    Section {
                        Toggle("Use old navigation tab bar", isOn: $useOldTabBar)
                    } footer: {
                        Text("Replaces the top navigation tab bar introduced on iOS 18 with the previous one. This only affects to iPadOS.")
                    }
                }
            }
            .navigationTitle("Advanced settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
