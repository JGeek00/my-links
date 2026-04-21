import SwiftUI

struct CollectionFormView: View {
    var collectionId: Int?
    var action: Enums.CollectionFormAction
    var onClose: () -> Void
    var onSuccess: (Collection, Enums.CollectionFormAction) -> Void
    
    @State private var collectionFormViewModel: CollectionFormViewModel
    
    init(collectionId: Int? = nil, action: Enums.CollectionFormAction, onClose: @escaping () -> Void, onSuccess: @escaping (Collection, Enums.CollectionFormAction) -> Void) {
        self.collectionId = collectionId
        self.action = action
        self.onClose = onClose
        self.onSuccess = onSuccess
        _collectionFormViewModel = State(initialValue: CollectionFormViewModel(collectionId: collectionId, action: action))
    }
        
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
            .navigationTitle(collectionFormViewModel.editingCollection != nil ? "Edit collection" : (collectionFormViewModel.parentCollection != nil) ? "New child collection" : "New collection")
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
                        collectionFormViewModel.onSave() { item in
                            onSuccess(item, collectionFormViewModel.editingCollection != nil ? .edit : .create)
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
