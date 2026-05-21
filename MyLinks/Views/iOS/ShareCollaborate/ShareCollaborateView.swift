import SwiftUI

struct ShareCollaborateView: View {
    var collection: Collection
    var onClose: () -> Void
    var onSave: (Collection) -> Void
    
    @State private var viewModel: ShareCollaborateViewModel
    
    init(collection: Collection, onClose: @escaping () -> Void, onSave: @escaping (Collection) -> Void) {
        self.collection = collection
        self.onClose = onClose
        self.onSave = onSave
        _viewModel = State(initialValue: ShareCollaborateViewModel(collection: collection))
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Make collection public", isOn: $viewModel.makeCollectionPublic)
                    if viewModel.makeCollectionPublic == true {
                        HStack {
                            Text(verbatim: viewModel.publicUrl)
                                .fontDesign(.monospaced)
                            Spacer()
                            Button {
                               viewModel.copyPublicUrlClipboard()
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .accessibilityLabel("Copy public URL")
                        }
                    }
                }
            }
            .navigationTitle("Share and collaborate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton(onClose: onClose)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.save { collection in
                            onSave(collection)
                        }
                    }
                    .glassProminentButtonStyleIfAvailable()
                }
            }
            .alert("Error", isPresented: $viewModel.savingErrorAlert) {
                Button {
                    viewModel.savingErrorAlert = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text(viewModel.savingErrorMessage)
            }
        }
        .interactiveDismissDisabled()
    }
}
