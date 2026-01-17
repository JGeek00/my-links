import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    let urlDataType = UTType.url.identifier
    let textDataType = UTType.utf8PlainText.identifier
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            print("Error: No extension item found")
            close()
            return
        }
        guard let items = extensionItem.attachments else {
            print("Error: No attachments found")
            close()
            return
        }
        
        let urls = items.filter() { $0.hasItemConformingToTypeIdentifier(urlDataType) }
        if let first = urls.first {
            handleUrl(attachment: first)
        }
        else {
            handleInvalidText()
        }
       
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                print("Error: Close notification received")
                self.close()
            }
        }
    }
    
    func handleUrl(attachment: NSItemProvider) {
        attachment.loadItem(forTypeIdentifier: urlDataType , options: nil) { (providedText, error) in
              if error != nil {
                  print("Error: handleUrl error: \(String(describing: error))")
                  self.close()
                  return
              }
            
            if let url = providedText as? NSURL {
                guard let urlString = url.absoluteString else {
                    print("Error: URL absoluteString is nil")
                    self.close()
                    return
                }
                
                DispatchQueue.main.async {
                    let contentView = UIHostingController(
                        rootView: ShareExtensionView {
                            self.close()
                        }
                        .environmentObject(ShareExtensionViewModel(url: urlString))
                    )
                    self.addChild(contentView)
                    self.view.addSubview(contentView.view)
                    
                    contentView.view.translatesAutoresizingMaskIntoConstraints = false
                    contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                    contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
                    contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                    contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
                }
            } else {
                print("Error: providedText is not NSURL")
                self.close()
                return
            }
        }
    }
    
    func handleInvalidText() {
        DispatchQueue.main.async {
            let contentView = UIHostingController(rootView: InvalidUrlView {
                print("Error: InvalidUrlView completion")
                self.close()
            })
            self.addChild(contentView)
            self.view.addSubview(contentView.view)
            
            contentView.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
            contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
        }
    }

    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
