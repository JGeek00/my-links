import SwiftUI

struct ImageViewerView: View {
    var link: Link
    var onClose: () -> Void
    
    @StateObject private var imageViewerViewModel: ImageViewerViewModel
    
    init(link: Link, onClose: @escaping () -> Void) {
        self.link = link
        self.onClose = onClose
        _imageViewerViewModel = StateObject(wrappedValue: ImageViewerViewModel(link: link))
    }
    
    var body: some View {
        let name = link.name! != "" ? link.name! : link.description! != "" ? link.description! : link.url!
        NavigationStack {
            Group {
                if imageViewerViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if imageViewerViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the image. Check your Internet connection and try again later.")
                        Button {
                            Task { await imageViewerViewModel.loadData(linkId: link.id!, setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else if imageViewerViewModel.imageData != nil {
                    ImageViewer(image: imageViewerViewModel.imageData!)
                }
                else {
                    ContentUnavailableView(
                        "Image unavailable",
                        systemImage: "photo",
                        description: Text("The image of the link is not available.")
                    )
                }
            }
            .navigationTitle(name)
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
                    HStack {
                        Button {
                            Task { await imageViewerViewModel.loadData(linkId: link.id!, setLoading: true) }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .disabled(imageViewerViewModel.loading == true)
                        Menu {
                            Button {
                                imageViewerViewModel.saveDocumentSheet = true
                            } label: {
                                Label("Download", systemImage: "square.and.arrow.down")
                            }
                            if imageViewerViewModel.data != nil {
                                ShareLink(
                                    "Share",
                                    item: imageViewerViewModel.data!,
                                    preview: SharePreview(name)
                                )
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .disabled(imageViewerViewModel.loading == true || imageViewerViewModel.data == nil)
                    }
                }
            }
            .sheet(isPresented: $imageViewerViewModel.saveDocumentSheet, content: {
                if imageViewerViewModel.data != nil {
                    DocumentPicker(data: imageViewerViewModel.data!, fileName: "\(name).png") { _ in
                        // --- //
                    } onError: {
                        imageViewerViewModel.savingErrorMessage = String(localized: "An error occured when saving the file")
                        imageViewerViewModel.savingErrorAlert.toggle()
                    } onCancelled: {
                        // --- //
                    }
                    .ignoresSafeArea()
                }
            })
            .alert("Error", isPresented: $imageViewerViewModel.savingErrorAlert) {
                Button("Close", role: .cancel) {
                    imageViewerViewModel.savingErrorAlert.toggle()
                }
            } message: {
                Text(imageViewerViewModel.savingErrorMessage)
            }
        }
    }
}
