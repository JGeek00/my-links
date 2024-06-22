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
            .overlay(alignment: .topLeading) {
                GeometryReader(content: { geometry in
                    Group {
                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.foreground)
                        }
                        .frame(width: 40, height: 40)
                        .background(.regularMaterial)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                    }
                    .offset(x: 12, y: 12)
                    Group {
                        Button {
                            Task { await imageViewerViewModel.loadData(linkId: link.id!, setLoading: true) }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.foreground)
                        }
                        .frame(width: 40, height: 40)
                        .background(.regularMaterial)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                    }
                    .offset(x: geometry.size.width - 52, y: 12)
                    Group {
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
                                .font(.system(size: 22))
                                .foregroundStyle(Color.foreground)
                        }
                        .disabled(imageViewerViewModel.loading == true || imageViewerViewModel.data == nil)
                        .frame(width: 40, height: 40)
                        .background(.regularMaterial)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                    }
                    .offset(x: geometry.size.width - 52, y: 70)
                })
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
