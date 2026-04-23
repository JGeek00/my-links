import SwiftUI

struct TagFormView: View {
    var mode: Enums.TagFormMode
    var onClose: () -> Void
    var onSuccess: (Tag) -> Void
    
    @State private var tagFormViewModel: TagFormViewModel
    
    init(tag: Tag? = nil, mode: Enums.TagFormMode, onClose: @escaping () -> Void, onSuccess: @escaping(Tag) -> Void) {
        self.mode = mode
        self.onClose = onClose
        self.onSuccess = onSuccess
        _tagFormViewModel = State(initialValue: TagFormViewModel(editingTag: tag))
    }
        
    var body: some View {
        NavigationStack {
            Form {
                TextField("Label", text: $tagFormViewModel.label)
            }
            .navigationTitle(tagFormViewModel.editingTag != nil ? "Edit tag" : "New tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        tagFormViewModel.discardChangesConfirmation = true
                    }
                    .confirmationDialog("Discard changes?", isPresented: $tagFormViewModel.discardChangesConfirmation) {
                        Button("Discard changes", role: .destructive) {
                            onClose()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        tagFormViewModel.onSave { tag in
                            onSuccess(tag)
                        }
                    } label: {
                        if tagFormViewModel.saving == true {
                            ProgressView()
                        }
                        else {
                            Text("Save")
                        }
                    }
                    .disabled(tagFormViewModel.saving)
                    .glassProminentButtonStyleIfAvailable()
                }
            }
            .alert("Error", isPresented: $tagFormViewModel.savingErrorAlert) {
                if #available(iOS 26.0, *) {
                    Button("Close", role: .close) {
                        tagFormViewModel.savingErrorAlert = false
                    }
                } else {
                    Button("Close") {
                        tagFormViewModel.savingErrorAlert = false
                    }
                }
            } message: {
                Text(verbatim: tagFormViewModel.savingErrorMessage)
            }
            .alert("Label is empty", isPresented: $tagFormViewModel.noLabel) {
                if #available(iOS 26.0, *) {
                    Button("Close", role: .close) {
                        tagFormViewModel.noLabel = false
                    }
                } else {
                    Button("Close") {
                        tagFormViewModel.noLabel = false
                    }
                }
            } message: {
                Text("A label is required to create a tag.")
            }
        }
    }
}
