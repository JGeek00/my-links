import SwiftUI

struct MenuBarTagsPickerView: View {
    var goBack: () -> Void
    
    @State private var menuBarTagsPickerViewModel: MenuBarTagsPickerViewModel
    
    init(tags: [String], goBack: @escaping () -> Void) {
        self.goBack = goBack
        _menuBarTagsPickerViewModel = State(initialValue: MenuBarTagsPickerViewModel(existingTags: tags))
    }
    
    @Environment(MenuBarFormViewModel.self) private var menuBarFormViewModel
    
    var body: some View {
        @Bindable var menuBarTagsPickerViewModel = menuBarTagsPickerViewModel
        VStack {
            HStack {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .padding(.horizontal, 2)
                        .padding(.vertical, 8)
                }
                Spacer()
                    .frame(width: 12)
                Text("Tags")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            Form {
                Section {
                    TagsTextField(tags: $menuBarTagsPickerViewModel.selectedTags, currentTextInput: $menuBarTagsPickerViewModel.currentTextInput) { removedTag in
                        menuBarTagsPickerViewModel.handleRemoveTag(tag: removedTag)
                    }
                    .onChange(of: menuBarTagsPickerViewModel.currentTextInput, initial: false) { _, newValue in
                        menuBarTagsPickerViewModel.getTagSuggestions(query: newValue)
                    }
                } header: {
                    Text("Current tags")
                } footer: {
                    Text("- Separe each tag by a comma (,) or by hitting enter.\n- Tap on an already added tag to remove it.\n- Write text to see suggestions.\n- Tap on a suggestion to add a tag.\n\n")
                }
                if menuBarTagsPickerViewModel.tagSuggestions.isEmpty && menuBarTagsPickerViewModel.loadingTagSuggestions == true {
                    ProgressView()
                        .controlSize(.small)
                }
                if !menuBarTagsPickerViewModel.tagSuggestions.isEmpty {
                    Section {
                        ForEach(menuBarTagsPickerViewModel.tagSuggestions, id: \.self) { tag in
                            Button {
                                menuBarTagsPickerViewModel.handleSelectTag(tag: tag)
                            } label: {
                                Text(verbatim: tag)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        HStack {
                            Text("Suggested tags")
                            if menuBarTagsPickerViewModel.loadingTagSuggestions == true {
                                Spacer()
                                ProgressView()
                                    .controlSize(.mini)
                            }
                        }
                    }
                    .animation(.default, value: menuBarTagsPickerViewModel.tagSuggestions)
                }
            }
            .formStyle(GroupedFormStyle())
        }
        .onChange(of: menuBarTagsPickerViewModel.selectedTags) { _, newValue in
            menuBarFormViewModel.selectedTags = newValue
        }
    }
}
