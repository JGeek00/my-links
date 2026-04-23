import SwiftUI

struct CollectionsPickerView: View {
    init() {}
    
    @Environment(\.dismiss) private var dismiss
    @Environment(LinkFormViewModel.self) private var linkFormViewModel
    
    @State private var searchText = ""
    
    var body: some View {
        let filtered = searchText != "" ? linkFormViewModel.availableCollections.filter { $0.name.lowercased().contains(searchText.lowercased()) } : linkFormViewModel.availableCollections
        List(filtered, id: \.self) { item in
            Button {
                linkFormViewModel.collection = item.id
                dismiss()
            } label: {
                HStack {
                    Text(verbatim: item.name)
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
