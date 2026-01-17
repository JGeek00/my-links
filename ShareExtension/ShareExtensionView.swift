import SwiftUI

struct ShareExtensionView: View {
    var onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @EnvironmentObject private var shareExtensionViewModel: ShareExtensionViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    @State private var discardAlert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if shareExtensionViewModel.invalidUrl == true {
                    ContentUnavailableView("Invalid URL", systemImage: "link", description: Text("The provided URL is not valid."))
                }
                else if shareExtensionViewModel.apiClient == nil {
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
                            let filtered = shareExtensionViewModel.collections
                            let selectedCollectionName = shareExtensionViewModel.getCollectionName()
                            if !shareExtensionViewModel.collections.isEmpty {
                                if filtered.count > Config.collectionsCountSelectorBreakpoint {
                                    NavigationLink {
                                        ShareExtensionCollectionsPickerView()
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text("Collection")
                                            if let name = selectedCollectionName {
                                                Spacer().frame(height: 6)
                                                Text(verbatim: name)
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(.gray)
                                            }
                                        }
                                    }
                                }
                                else {
                                    Picker("Collection", selection: $shareExtensionViewModel.collection) {
                                        if !filtered.isEmpty {
                                            ForEach(filtered, id: \.self) { item in
                                                Text(item.name!)
                                                    .tag(item.id!)
                                            }
                                        }
                                        else {
                                            Text("Unorganized")
                                                .tag(0)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            NavigationLink {
                                ShareExtensionTagsPickerView()
                            } label: {
                                VStack(alignment: .leading) {
                                    Text("Tags")
                                    if shareExtensionViewModel.selectedTags.isEmpty == false {
                                        Spacer().frame(height: 6)
                                        Text(verbatim: shareExtensionViewModel.selectedTags.count <= Config.selectedTagsCountLabelBreakpoint ? shareExtensionViewModel.selectedTags.joined(separator: ", ") : String(localized: "\(shareExtensionViewModel.selectedTags.count) tags selected"))
                                            .font(.system(size: 14))
                                            .foregroundStyle(.gray)
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
                    CloseButton {
                        discardAlert = true
                    }
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
                        .glassProminentButtonStyleIfAvailable()
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
        }
        .fontDesign(.rounded)
        .onChange(of: shareExtensionViewModel.apiClient, { oldValue, newValue in
            if oldValue == nil && newValue != nil {
                Task { await shareExtensionViewModel.loadData() }
            }
        })
        .onAppear {
            if shareExtensionViewModel.apiClient != nil {
                Task { await shareExtensionViewModel.loadData() }
            }
        }
    }
}
