import SwiftUI

struct ElementsView: View {
    
    @EnvironmentObject private var navigationProvider: NavigationProvider
    
    var body: some View {
        NavigationStack(path: $navigationProvider.library) {
            List {
                NavigationLink {
                    LinksView()
                        .environmentObject(LinksViewModel.shared)
                } label: {
                    Label("Links", systemImage: "link")
                }
                NavigationLink {
                    CollectionsView(navigationFlow: .library)
                } label: {
                    Label("Collections", systemImage: "folder")
                }
                NavigationLink {
                    TagsView(navigationFlow: .library)
                } label: {
                    Label("Tags", systemImage: "tag")
                }
            }
            .navigationTitle("Elements")
        }
    }
}
