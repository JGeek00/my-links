import SwiftUI

@MainActor
@Observable
class ShareExtensionTagsPickerViewModel {
    @ObservationIgnored private let apiClientRepository: ShareExtensionApiClientRepository
    
    @ObservationIgnored private var suggestionTask: Task<Void, Never>? = nil
    
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
        suggestionTask?.cancel()
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            tagSuggestions = []
            loadingTagSuggestions = false
            return
        }
        
        suggestionTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            if Task.isCancelled { return }
            await self?.fetchSuggestions(query: trimmed)
        }
    }
    
    private func fetchSuggestions(query: String) async {
        guard let instance = apiClientRepository.instance else { return }
        self.loadingTagSuggestions = true
        let result = await instance.tags.fetchTags(search: query)
        if let tags = result.data?.data?.tags {
            DispatchQueue.main.async {
                withAnimation {
                    self.tagSuggestions = tags.map() { $0.name }
                    self.loadingTagSuggestions = false
                }
            }
        }
    }
    
    func handleSelectTag(tag: String) {
        selectedTags.append(tag)
        currentTextInput = ""
    }
}

