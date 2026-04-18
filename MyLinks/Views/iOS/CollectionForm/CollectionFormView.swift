import SwiftUI

struct CollectionFormView: View {
    var parentCollectionId: Int?
    var onClose: () -> Void
    var onSuccess: (Collection, Enums.LinkTaskCompleted) -> Void
    
    @State private var collectionFormViewModel: CollectionFormViewModel
    
    init(parentCollectionId: Int? = nil, onClose: @escaping () -> Void, onSuccess: @escaping (Collection, Enums.LinkTaskCompleted) -> Void) {
        self.parentCollectionId = parentCollectionId
        self.onClose = onClose
        self.onSuccess = onSuccess
        _collectionFormViewModel = State(initialValue: CollectionFormViewModel(collectionId: parentCollectionId))
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
            .navigationTitle(collectionFormViewModel.editingCollection != nil ? collectionFormViewModel.editingCollection != nil ? "Edit subcollection" : "Edit collection" : parentCollectionId != nil ? "New subcollection" : "New collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        onClose()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        collectionFormViewModel.onSave(parentId: parentCollectionId) { item in
                            onSuccess(item, collectionFormViewModel.editingCollection != nil ? .edit : .create)
                        }
                    } label: {
                        if collectionFormViewModel.saving == true {
                            ProgressView()
                        }
                        else {
                            Text("Save")
                        }
                    }
                    .glassProminentButtonStyleIfAvailable()
                    .disabled(collectionFormViewModel.saving)
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
    }
}
