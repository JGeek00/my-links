import SwiftUI

struct TagFormView: View {
    var onClose: () -> Void
    
    @State private var tagsViewModel: TagsViewModel
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        _tagsViewModel = State(initialValue: TagsViewModel())
    }
    
    @State private var label: String = ""
    @State private var saving: Bool = false
    @State private var error: Bool = false
    @State private var noLabel: Bool = false
    @State private var showConfirmationAlert = false
    
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
            .navigationTitle("New tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        showConfirmationAlert = true
                    }
                    .confirmationDialog("Discard changes?", isPresented: $showConfirmationAlert) {
                        Button("Discard changes", role: .destructive) {
                            onClose()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await createTag()
                        }
                    } label: {
                        if saving == true {
                            ProgressView()
                        }
                        else {
                            Text("Save")
                        }
                    }
                    .disabled(saving)
                    .glassProminentButtonStyleIfAvailable()
                }
            }
            .alert("Error", isPresented: $error) {
                if #available(iOS 26.0, *) {
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
                if #available(iOS 26.0, *) {
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
