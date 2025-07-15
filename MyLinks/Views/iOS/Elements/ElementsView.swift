import SwiftUI

struct ElementsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    LinksView()
                        .environmentObject(LinksViewModel.shared)
                } label: {
                    Label("Links", systemImage: "link")
                }
                NavigationLink {
                    CollectionsView()
                } label: {
                    Label("Collections", systemImage: "folder")
                }
                NavigationLink {
                    TagsView()
                } label: {
                    Label("Tags", systemImage: "tag")
                }
            }
            .navigationTitle("Elements")
        }
    }
}
