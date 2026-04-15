import SwiftUI

struct TagsPickerView: View {
    @EnvironmentObject private var tagsProvider: TagsProvider
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    
    @State private var addTagAlert = false
    @State private var newTagName = ""
    @State private var searchText = ""
    
    var body: some View {
        let mapped = (tagsProvider.data.map() { $0.name }) + linkFormViewModel.localTags
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
                        if linkFormViewModel.selectedTags.contains(item) {
                            linkFormViewModel.selectedTags = linkFormViewModel.selectedTags.filter() { $0 != item }
                        }
                        else {
                            linkFormViewModel.selectedTags.append(item)
                        }
                    } label: {
                        HStack {
                            Text(item)
                                .foregroundStyle(Color.foreground)
                            Spacer()
                            if linkFormViewModel.selectedTags.contains(item) {
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
                linkFormViewModel.localTags.append(newTagName)
                linkFormViewModel.selectedTags.append(newTagName)
            }
            TextField("Tag name", text: $newTagName)
        }
    }
}
