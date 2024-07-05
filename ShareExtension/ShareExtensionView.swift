import SwiftUI

struct ShareExtensionView: View {
    var onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @EnvironmentObject private var shareExtensionViewModel: ShareExtensionViewModel
    
    @State private var discardAlert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if shareExtensionViewModel.apiClient == nil {
                    ContentUnavailableView("Server unavailable", systemImage: "server.rack", description: Text("Open the app to create a connection to a server."))
                }
                else if shareExtensionViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                }
                else if shareExtensionViewModel.loadError == true {
                    ContentUnavailableView("Cannot connect to the server", systemImage: "exclamationmark.circle", description: Text("Check your internet connection and try again."))
                }
                else {
                    Form {
                        Section {
                            TextField("URL", text: $shareExtensionViewModel.url)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .keyboardType(.URL)
                                .disabled(true)
                        }
                        Section {
                            TextField("Name", text: $shareExtensionViewModel.name)
                            TextField("Description", text: $shareExtensionViewModel.description, axis: .vertical)
                        }
                        Section {
                            if !shareExtensionViewModel.collections.isEmpty {
                                Picker("Collection", selection: $shareExtensionViewModel.collection) {
                                    ForEach(shareExtensionViewModel.collections, id: \.self) { item in
                                        Text(item.name!)
                                            .tag(item.id!)
                                    }
                                }
                            }
                            NavigationLink {
                                TagsPickerView()
                            } label: {
                                HStack {
                                    Text("Tags")
                                    if shareExtensionViewModel.selectedTags.isEmpty == false {
                                        Text(String(shareExtensionViewModel.selectedTags.count))
                                            .font(.system(size: 12))
                                            .fontWeight(.semibold)
                                            .padding(6)
                                            .foregroundStyle(Color.white)
                                            .background(Color.accentColor)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.listBackground)
            .navigationTitle("Create new link")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        discardAlert = true
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
                if shareExtensionViewModel.apiClient != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            shareExtensionViewModel.onSave {
                                onClose()
                            }
                        } label: {
                            if shareExtensionViewModel.saving == true {
                                ProgressView()
                            }
                            else {
                                Text("Save")
                            }
                        }
                        .disabled(shareExtensionViewModel.saving || shareExtensionViewModel.loading == true || shareExtensionViewModel.loadError == true)
                    }
                }
            }
            .alert("Discard changes", isPresented: $discardAlert) {
                Button("Cancel", role: .cancel) {
                    discardAlert = false
                }
                Button("Discard", role: .destructive) {
                    onClose()
                }
            } message: {
                Text("Are you sure you want to discard the changes? This action cannot be reverted.")
            }
            .alert("Error", isPresented: $shareExtensionViewModel.saveError) {
                Button("Close", role: .cancel) {
                    shareExtensionViewModel.saveError = false
                }
            } message: {
                Text("An error occured when saving the link.")
            }
            .alert("Invalid URL", isPresented: $shareExtensionViewModel.invalidUrl) {
                Button("Close", role: .cancel) {
                    onClose()
                }
            } message: {
                Text("The provided URL is not valid")
            }
        }
        .fontDesign(.rounded)
        .onAppear {
            if shareExtensionViewModel.apiClient != nil {
                Task { await shareExtensionViewModel.loadData() }
            }
        }
    }
}

private struct TagsPickerView: View {
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

