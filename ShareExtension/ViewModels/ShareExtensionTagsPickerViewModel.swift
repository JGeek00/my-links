import SwiftUI

@MainActor
@Observable
class ShareExtensionTagsPickerViewModel {
    @ObservationIgnored private let apiClientRepository: ShareExtensionApiClientRepository
    
    init(existingTags: [String] = []) {
        self.apiClientRepository = ShareExtensionRepositoriesContainer.shared.apiClientRepository
        self.selectedTags = existingTags
    }
    
    init(apiClientRepository: ShareExtensionApiClientRepository, existingTags: [String] = []) {
        self.apiClientRepository = apiClientRepository
        self.selectedTags = existingTags
    }
    
    var currentTextInput: String = ""
    var selectedTags: [String] = []
    var loadingTagSuggestions = false
    var tagSuggestions: [String] = []
    
    func getTagSuggestions(query: String) {
        guard let instance = apiClientRepository.instance else { return }
        Task {
            self.loadingTagSuggestions = true
            let result = await instance.tags.fetchTags()
            if let tags = result.data?.data?.tags {
                DispatchQueue.main.async {
                    withAnimation {
                        self.tagSuggestions = tags.map() { $0.name }
                        self.loadingTagSuggestions = false
                    }
                }
            }
        }
    }
    
    func handleSelectTag(tag: String) {
        selectedTags.append(tag)
        currentTextInput = ""
    }
}

