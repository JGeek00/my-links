import SwiftUI

struct LinkFormView: View {
    var onClose: () -> Void
    var onSuccess: (Link, Enums.LinkTaskCompleted) -> Void
    
    init(onClose: @escaping () -> Void, onSuccess: @escaping (Link, Enums.LinkTaskCompleted) -> Void) {
        self.onClose = onClose
        self.onSuccess = onSuccess
    }
    
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("URL", text: $linkFormViewModel.url)
                        .autocorrectionDisabled()
                        .disabled(linkFormViewModel.editingLink != nil)
                }
                Section {
                    TextField("Name", text: $linkFormViewModel.name)
                    TextField("Description", text: $linkFormViewModel.description, axis: .vertical)
                }
                Section {
                    let filtered = collectionsProvider.data.filter() { $0.name != nil && $0.id != nil }
                    Picker("Collection", selection: $linkFormViewModel.collection) {
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
                    NavigationLink {
                        TagsPickerView()
                    } label: {
                        HStack {
                            Text("Tags")
                            if linkFormViewModel.selectedTags.isEmpty == false {
                                Text(String(linkFormViewModel.selectedTags.count))
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
            .frame(minHeight: 250)
            .formStyle(GroupedFormStyle())
            .disabled(linkFormViewModel.saving)
            .navigationTitle(linkFormViewModel.editingLink != nil ? "Edit link" : "New link")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onClose()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        linkFormViewModel.onSave() { newLink in
                            onSuccess(newLink, linkFormViewModel.editingLink != nil ? .edit : .create)
                        }
                    } label: {
                        if linkFormViewModel.saving == true {
                            ProgressView()
                        }
                        else {
                            Text("Save")
                        }
                    }
                    .disabled(linkFormViewModel.saving)
                }
            }
            .alert("Validation error", isPresented: $linkFormViewModel.validationErrorAlert) {
                Button {
                    linkFormViewModel.validationErrorAlert = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text(linkFormViewModel.validationErrorMessage)
            }
            .alert("Error", isPresented: $linkFormViewModel.savingErrorAlert) {
                Button {
                    linkFormViewModel.savingErrorAlert = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text(linkFormViewModel.savingErrorMessage)
            }
        }
        .padding()
        
    }
}
