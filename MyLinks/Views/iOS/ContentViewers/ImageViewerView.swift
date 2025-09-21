import SwiftUI

struct ImageViewerView: View {
    var link: Link
    var onClose: () -> Void
    
    @EnvironmentObject private var imageViewerViewModel: ImageViewerViewModel
    
    init(link: Link, onClose: @escaping () -> Void) {
        self.link = link
        self.onClose = onClose
    }
    
    var body: some View {
        let name = link.name! != "" ? link.name! : link.description! != "" ? link.description! : link.url!
        let fileName = (name.hasSuffix(".") ? String(name.dropLast()) : name).replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "/", with: "")
        NavigationStack {
            Group {
                if imageViewerViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
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
                    .transition(.opacity)
                }
                else if imageViewerViewModel.imageData != nil {
                    ImageViewer(image: imageViewerViewModel.imageData!)
                        .transition(.opacity)
                }
                else {
                    ContentUnavailableView(
                        "Image unavailable",
                        systemImage: "photo",
                        description: Text("The image of the link is not available.")
                    )
                    .transition(.opacity)
                }
            }
            .navigationTitle(link.name ?? "Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        onClose()
                    }
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
                            if let i = imageViewerViewModel.imageData {
                                ShareLink(
                                    "Share",
                                    item: Image(uiImage: i),
                                    preview: SharePreview(fileName)
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
                if let image = imageViewerViewModel.data {
                    DocumentPicker(data: image, fileName: "\(fileName).png") { _ in
                        // --- //
                    } onError: {
                        Task {
                            imageViewerViewModel.savingErrorMessage = String(localized: "An error occured when saving the file")
                            imageViewerViewModel.savingErrorAlert.toggle()
                        }
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
