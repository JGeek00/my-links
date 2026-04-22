import SwiftUI

struct TagsPickerView: View {
    @State private var tagsPickerViewModel: TagsPickerViewModel
    
    init(existingTags: [String]) {
        _tagsPickerViewModel = State(initialValue: TagsPickerViewModel(existingTags: existingTags))
    }
    
    @Environment(LinkFormViewModel.self) private var linkFormViewModel
    
    var body: some View {
        @Bindable var linkFormViewModel = linkFormViewModel
        Form {
            Section("Current tags") {
                TagsTextField(tags: $tagsPickerViewModel.selectedTags, currentTextInput: $tagsPickerViewModel.currentTextInput)
                    .onChange(of: tagsPickerViewModel.currentTextInput, initial: false) { _, newValue in
                        tagsPickerViewModel.getTagSuggestions(query: newValue)
                    }
            }
            if tagsPickerViewModel.tagSuggestions.isEmpty && tagsPickerViewModel.loadingTagSuggestions == true {
                ProgressView()
                    .controlSize(.small)
            }
            if !tagsPickerViewModel.tagSuggestions.isEmpty {
                Section {
                    ForEach(tagsPickerViewModel.tagSuggestions, id: \.self) { tag in
                        Button {
                            tagsPickerViewModel.handleSelectTag(tag: tag)
                        } label: {
                            Text(verbatim: tag)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    HStack {
                        Text("Suggested tags")
                        if tagsPickerViewModel.loadingTagSuggestions == true {
                            Spacer()
                            ProgressView()
                                .controlSize(.mini)
                        }
                    }
                }
                .animation(.default, value: tagsPickerViewModel.tagSuggestions)
            }
        }
        .formStyle(GroupedFormStyle())
        .navigationTitle("Tags")
        .onChange(of: tagsPickerViewModel.selectedTags) { _, newValue in
            linkFormViewModel.selectedTags = newValue
        }
    }
}
