import SwiftUI

struct CollectionFormView: View {
    var parentCollection: Collection?
    var onClose: () -> Void
    var onSuccess: (Collection, Enums.LinkTaskCompleted) -> Void
    
    init(parentCollection: Collection? = nil, onClose: @escaping () -> Void, onSuccess: @escaping (Collection, Enums.LinkTaskCompleted) -> Void) {
        self.parentCollection = parentCollection
        self.onClose = onClose
        self.onSuccess = onSuccess
    }
    
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $collectionFormViewModel.name)
                    TextField("Description", text: $collectionFormViewModel.description, axis: .vertical)
                }
                Section {
                    ColorPicker("Color", selection: $collectionFormViewModel.color)
                }
            }
            .formStyle(GroupedFormStyle())
            .navigationTitle(collectionFormViewModel.editingCollection != nil ? collectionFormViewModel.editingCollection != nil ? "Edit subcollection" : "Edit collection" : parentCollection != nil ? "New subcollection" : "New collection")
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
                        Task {
                            await collectionFormViewModel.onSave(parentId: parentCollection?.id) { item in
                                onSuccess(item, collectionFormViewModel.editingCollection != nil ? .edit : .create)
                            }
                        }
                    } label: {
                        Text("Save")
                    }
                    .disabled(collectionFormViewModel.saving)
                }
                if collectionFormViewModel.saving {
                    ToolbarItem(placement: .destructiveAction) {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .alert("Invalid data", isPresented: $collectionFormViewModel.nameRequiredAlert) {
                Button {
                    collectionFormViewModel.nameRequiredAlert = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text("Name field is required.")
            }
            .alert("Error", isPresented: $collectionFormViewModel.savingErrorAlert) {
                Button {
                    collectionFormViewModel.savingErrorAlert = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text(collectionFormViewModel.savingErrorMessage)
            }
        }
        .frame(width: 500, height: 300)
    }
}
