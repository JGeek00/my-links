import SwiftUI

struct CollectionFormView: View {
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
            .navigationTitle(collectionFormViewModel.editingId != nil ? "Edit collection" : "New collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        collectionFormViewModel.sheetOpen.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.listItemValue)
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        collectionFormViewModel.onSave()
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
        .onChange(of: collectionFormViewModel.sheetOpen) { value in
            if value == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    collectionFormViewModel.reset()
                }
            }
        }
    }
}
