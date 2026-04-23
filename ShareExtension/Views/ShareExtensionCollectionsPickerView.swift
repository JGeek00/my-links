import SwiftUI

struct ShareExtensionCollectionsPickerView: View {
    init() {}
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ShareExtensionViewModel.self) private var shareExtensionViewModel
    
    @State private var searchText = ""
    
    var body: some View {
        let collections = shareExtensionViewModel.collections
        let filtered = searchText != "" ? collections.filter { $0.name.lowercased().contains(searchText.lowercased()) } : collections
        List(filtered, id: \.self) { item in
            Button {
                shareExtensionViewModel.collection = item.id
                dismiss()
            } label: {
                HStack {
                    Text(verbatim: item.name)
                        .foregroundColor(.foreground)
                    Spacer()
                    if shareExtensionViewModel.collection == item.id {
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
