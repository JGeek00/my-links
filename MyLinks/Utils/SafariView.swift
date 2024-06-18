import SwiftUI
import SafariServices

struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
        return
    }
}

func openSafariView(_ url: String) {
    let vc = SFSafariViewController(url: URL(string: url)!)
    UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
}
