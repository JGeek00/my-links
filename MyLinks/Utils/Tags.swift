func filterSuggestionsWithSelectedTags(suggestions: [Tag], existingTags: [String]) -> [String] {
    let mapped = suggestions.map() { $0.name }
    return mapped.filter() { existingTags.map() { $0.lowercased() }.contains($0.lowercased()) == false }
}
