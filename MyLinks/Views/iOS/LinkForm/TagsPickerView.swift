import SwiftUI

struct TagsPickerView: View {
    @State private var tagsPickerViewModel: TagsPickerViewModel
    
    init(existingTags: [String]) {
        _tagsPickerViewModel = State(initialValue: TagsPickerViewModel(existingTags: existingTags))
    }
    
    @Environment(LinkFormViewModel.self) private var linkFormViewModel
    
    var body: some View {
        @Bindable var linkFormViewModel = linkFormViewModel
        List {
            Section("Current tags") {
                TagsTextField(tags: $tagsPickerViewModel.selectedTags, currentTextInput: $tagsPickerViewModel.currentTextInput)
                    .onChange(of: tagsPickerViewModel.currentTextInput, initial: false) { _, newValue in
                        tagsPickerViewModel.getTagSuggestions(query: newValue)
                    }
            }
            if tagsPickerViewModel.tagSuggestions.isEmpty && tagsPickerViewModel.loadingTagSuggestions == true {
                ProgressView()
            }
            if !tagsPickerViewModel.tagSuggestions.isEmpty {
                Section {
                    ForEach(tagsPickerViewModel.tagSuggestions, id: \.self) { tag in
                        Button {
                            tagsPickerViewModel.handleSelectTag(tag: tag)
                        } label: {
                            Text(verbatim: tag)
                        }
                        .foregroundStyle(Color.foreground)
                        .onAppear {
                            if tag == tagsPickerViewModel.tagSuggestions.last {
                                tagsPickerViewModel.fetchMore()
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Suggested tags")
                        if tagsPickerViewModel.loadingTagSuggestions == true {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .animation(.default, value: tagsPickerViewModel.tagSuggestions)
            }
        }
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: tagsPickerViewModel.selectedTags) { _, newValue in
            linkFormViewModel.selectedTags = newValue
        }
    }
}
