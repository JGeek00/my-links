import SwiftUI

struct TagFormView: View {
    var onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @Environment(TagsViewModel.self) private var tagsViewModel
    
    @State private var label: String = ""
    @State private var saving: Bool = false
    @State private var error: Bool = false
    @State private var noLabel: Bool = false
    
    func createTag() async {
        if label == "" {
            noLabel = true
            return
        }
        
        saving = true
        let result = await tagsViewModel.createTag(name: label)
        if result == true {
            onClose()
        }
        else {
            error = true
        }
        saving = false
    }
        
    var body: some View {
        NavigationStack {
            Form {
                TextField("Label", text: $label)
            }
            .formStyle(GroupedFormStyle())
            .navigationTitle("New tag")
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
                            await createTag()
                        }
                    } label: {
                        Text("Save")
                    }
                    .disabled(saving)
                }
                if saving {
                    ToolbarItem(placement: .destructiveAction) {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .alert("Error", isPresented: $error) {
                if #available(macOS 26.0, *) {
                    Button("Close", role: .close) {
                        error = false
                    }
                } else {
                    Button("Close") {
                        error = false
                    }
                }
            } message: {
                Text("An error occured when creating the tag. Please try again.")
            }
            .alert("Label is empty", isPresented: $noLabel) {
                if #available(macOS 26.0, *) {
                    Button("Close", role: .close) {
                        noLabel = false
                    }
                } else {
                    Button("Close") {
                        noLabel = false
                    }
                }
            } message: {
                Text("A label is required to create a tag.")
            }

        }
    }
}
