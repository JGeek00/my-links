import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    var data: Data
    var fileName: String
    var didPickDocuments: ([URL]) -> Void
    var onError: () -> Void
    var onCancelled: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
        } catch {
            onError()
        }
        
        let controller = UIDocumentPickerViewController(forExporting: [fileURL])
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.didPickDocuments(urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            self.parent.onCancelled()
        }
    }
}
