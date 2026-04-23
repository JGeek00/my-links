import Foundation
import SwiftUI

@MainActor
@Observable
class TagFormViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let tagManagerRepository: TagManagerRepository
    
    var editingTag: Tag? = nil
    
    var label: String = ""
    
    var noLabel: Bool = false
    var saving = false
    var savingErrorMessage = ""
    var savingErrorAlert = false
    
    var discardChangesConfirmation = false
    
    init(editingTag: Tag? = nil, apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, tagManagerRepository: TagManagerRepository = RepositoriesContainer.shared.tagManagerRepository) {
        self.apiClientRepository = apiClientRepository
        self.tagManagerRepository = tagManagerRepository
               
        self.editingTag = editingTag
        if let editingTag = editingTag {
            self.label = editingTag.name
        }
    }
        
    func onSave(onSuccess: @escaping (Tag) -> Void, onError: ((Int?) -> Void)? = nil) {
        if label.isEmpty {
            noLabel = true
            return
        }
        Task {
            if var editingTag = editingTag {
                editingTag.name = label
                await tagManagerRepository.editTag(id: editingTag.id, body: editingTag) { processing in
                    self.saving = processing
                } onSuccess: { link in
                    onSuccess(link)
                } onError: { statusCode in
                    if let onError = onError {
                        onError(statusCode)
                    }
                    guard let statusCode = statusCode else {
                        self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                        self.savingErrorAlert = true
                        return
                    }
                    self.savingErrorMessage = "Error \(statusCode)."
                    self.savingErrorAlert = true
                }
            }
            else {
                await tagManagerRepository.createTag(name: label) { processing in
                    self.saving = processing
                } onSuccess: { tag in
                    onSuccess(tag)
                } onError: { statusCode in
                    if let onError = onError {
                        onError(statusCode)
                    }
                    guard let statusCode = statusCode else {
                        self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                        self.savingErrorAlert = true
                        return
                    }
                    self.saving = false
                    self.savingErrorMessage = "Error \(statusCode)."
                    self.savingErrorAlert = true
                }
            }
        }
    }
}
