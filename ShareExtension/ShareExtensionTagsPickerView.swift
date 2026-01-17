import SwiftUI

struct ShareExtensionTagsPickerView: View {
    @EnvironmentObject private var shareExtensionViewModel: ShareExtensionViewModel
    
    @State private var addTagAlert = false
    @State private var newTagName = ""
    @State private var searchText = ""
    
    var body: some View {
        let mapped = (shareExtensionViewModel.tags.map() { $0.name! }) + shareExtensionViewModel.localTags
        Group {
            if mapped.isEmpty {
                ContentUnavailableView {
                    Label("No tags created", systemImage: "tag")
                } description: {
                    Text("Add tags to links to see them here.")
                }
            }
            else {
                let searched = searchText != "" ? mapped.filter() { $0.lowercased().contains(searchText.lowercased()) } : mapped
                List(searched, id: \.self) { item in
                    Button {
                        if shareExtensionViewModel.selectedTags.contains(item) {
                            shareExtensionViewModel.selectedTags = shareExtensionViewModel.selectedTags.filter() { $0 != item }
                        }
                        else {
                            shareExtensionViewModel.selectedTags.append(item)
                        }
                    } label: {
                        HStack {
                            Text(item)
                                .foregroundStyle(Color.foreground)
                            Spacer()
                            if shareExtensionViewModel.selectedTags.contains(item) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                .animation(.default, value: searched)
            }
        }
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add tag", systemImage: "plus") {
                    newTagName = ""
                    addTagAlert.toggle()
                }
            }
        }
        .searchable(text: $searchText)
        .background(Color.listBackground)
        .alert("Add tag", isPresented: $addTagAlert) {
            Button("Cancel", role: .cancel) {
                addTagAlert.toggle()
            }
            Button("Save") {
                shareExtensionViewModel.localTags.append(newTagName)
                shareExtensionViewModel.selectedTags.append(newTagName)
            }
            TextField("Tag name", text: $newTagName)
        }
    }
}
