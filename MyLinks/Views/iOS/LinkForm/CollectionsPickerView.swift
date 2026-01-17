import SwiftUI

struct CollectionsPickerView: View {
    init() {}
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    
    @State private var searchText = ""
    
    var body: some View {
        let collections = collectionsProvider.data.filter() { $0.name != nil && $0.id != nil }
        let filtered = searchText != "" ? collections.filter { $0.name!.lowercased().contains(searchText.lowercased()) } : collections
        List(filtered, id: \.self) { item in
            Button {
                if let id = item.id {
                    linkFormViewModel.collection = id
                    dismiss()
                }
            } label: {
                HStack {
                    Text(verbatim: "\(item.name ?? "")")
                        .foregroundColor(.foreground)
                    Spacer()
                    if linkFormViewModel.collection == item.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .animation(.default, value: filtered)
        .searchable(text: $searchText, prompt: "Search collections")
        .navigationTitle("Collections")
        .navigationBarTitleDisplayMode(.inline)
    }
}
