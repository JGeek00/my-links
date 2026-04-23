import SwiftUI

struct TagFormView: View {
    var mode: Enums.TagFormMode
    var onClose: () -> Void
    var onSuccess: () -> Void
    
    @State private var tagFormViewModel: TagFormViewModel
    
    init(tag: Tag? = nil, mode: Enums.TagFormMode, onClose: @escaping () -> Void, onSuccess: @escaping() -> Void) {
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
            .formStyle(GroupedFormStyle())
            .navigationTitle(tagFormViewModel.editingTag != nil ? "Edit tag" : "New tag")
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
                        tagFormViewModel.onSave { tag in
                            onSuccess()
                        }
                    } label: {
                        Text("Save")
                    }
                    .disabled(tagFormViewModel.saving)
                }
                if tagFormViewModel.saving {
                    ToolbarItem(placement: .destructiveAction) {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .alert("Error", isPresented: $tagFormViewModel.savingErrorAlert) {
                if #available(macOS 26.0, *) {
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
                if #available(macOS 26.0, *) {
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
