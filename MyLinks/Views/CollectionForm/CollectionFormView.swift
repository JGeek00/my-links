import SwiftUI

struct CollectionFormView: View {
    var onClose: () -> Void
    var onSuccess: (Collection, Enums.LinkTaskCompleted) -> Void
    
    init(onClose: @escaping () -> Void, onSuccess: @escaping (Collection, Enums.LinkTaskCompleted) -> Void) {
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
            .navigationTitle(collectionFormViewModel.editingCollection != nil ? "Edit collection" : "New collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await collectionFormViewModel.onSave() { item in
                                onSuccess(item, collectionFormViewModel.editingCollection != nil ? .edit : .create)
                            }
                        }
                    } label: {
                        if collectionFormViewModel.saving == true {
                            ProgressView()
                        }
                        else {
                            Text("Save")
                        }
                    }
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
