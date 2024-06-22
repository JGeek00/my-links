import SwiftUI
import PDFKit
import MobileCoreServices

struct PDFViewerView: View {
    var link: Link
    var onClose: () -> Void
    
    @StateObject private var pdfViewerViewModel: PdfViewerViewModel

    init(link: Link, onClose: @escaping () -> Void) {
        self.link = link
        self.onClose = onClose
        _pdfViewerViewModel = StateObject(wrappedValue: PdfViewerViewModel(link: link))
    }
    
    var body: some View {
        let name = link.name! != "" ? link.name! : link.description! != "" ? link.description! : link.url!
        NavigationStack {
            Group {
                if pdfViewerViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if pdfViewerViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the PDF. Check your Internet connection and try again later.")
                        Button {
                            Task { await pdfViewerViewModel.loadData(linkId: link.id!, setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else if pdfViewerViewModel.pdfData != nil {
                    PDFKitView(showing: pdfViewerViewModel.pdfData!)
                }
                else {
                    Rectangle()
                        .foregroundStyle(Color.clear)
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
                            Task { await pdfViewerViewModel.loadData(linkId: link.id!, setLoading: true) }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .disabled(pdfViewerViewModel.loading == true)
                        Menu {
                            Button {
                                pdfViewerViewModel.saveDocumentToStorage(linkId: link.id!)
                            } label: {
                                Label("Download", systemImage: "square.and.arrow.down")
                            }
                            if pdfViewerViewModel.data != nil {
                                ShareLink(
                                    "Share",
                                    item: pdfViewerViewModel.data!,
                                    preview: SharePreview(name)
                                )
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .disabled(pdfViewerViewModel.loading == true || pdfViewerViewModel.data == nil)
                    }
                }
            }
            .sheet(isPresented: $pdfViewerViewModel.saveDocumentSheet, content: {
                if pdfViewerViewModel.data != nil {
                    DocumentPicker(data: pdfViewerViewModel.data!, fileName: "\(name).pdf") { _ in
                        // --- //
                    } onError: {
                        pdfViewerViewModel.savingErrorMessage = String(localized: "An error occured when saving the file")
                        pdfViewerViewModel.savingErrorAlert.toggle()
                    } onCancelled: {
                        // --- //
                    }
                    .ignoresSafeArea()
                }
            })
            .alert("Error", isPresented: $pdfViewerViewModel.savingErrorAlert) {
                Button("Close", role: .cancel) {
                    pdfViewerViewModel.savingErrorAlert.toggle()
                }
            } message: {
                Text(pdfViewerViewModel.savingErrorMessage)
            }
        }
    }
}

