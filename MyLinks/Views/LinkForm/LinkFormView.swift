import SwiftUI

struct LinkFormView: View {
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("URL", text: $linkFormViewModel.url)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .disabled(linkFormViewModel.editingLink != nil)
                }
                Section {
                    TextField("Name", text: $linkFormViewModel.name)
                    TextField("Description", text: $linkFormViewModel.description, axis: .vertical)
                }
                Section {
                    let filtered = collectionsProvider.data.filter() { $0.name != nil && $0.id != nil }
                    Picker("Collection", selection: $linkFormViewModel.collection) {
                        if !filtered.isEmpty {
                            ForEach(filtered, id: \.self) { item in
                                Text(item.name!)
                                    .tag(item.id!)
                            }
                        }
                        else {
                            Text("Unorganized")
                                .tag(1)
                        }
                    }
                    if !tagsProvider.data.isEmpty {
                        NavigationLink {
                            TagsPickerView()
                        } label: {
                            HStack {
                                Text("Tags")
                                if linkFormViewModel.selectedTags.isEmpty == false {
                                    Text(String(linkFormViewModel.selectedTags.count))
                                        .font(.system(size: 12))
                                        .fontWeight(.semibold)
                                        .padding(6)
                                        .foregroundStyle(Color.white)
                                        .background(Color.accentColor)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                }
            }
            .disabled(linkFormViewModel.saving)
            .navigationTitle(linkFormViewModel.editingLink != nil ? "Edit link" : "New link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        linkFormViewModel.sheetOpen.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        linkFormViewModel.onSave()
                    } label: {
                        if linkFormViewModel.saving == true {
                            ProgressView()
                        }
                        else {
                            Text("Save")
                        }
                    }
                    .disabled(linkFormViewModel.saving)
                }
            }
            .alert("Validation error", isPresented: $linkFormViewModel.validationErrorAlert) {
                Button {
                    linkFormViewModel.validationErrorAlert = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text(linkFormViewModel.validationErrorMessage)
            }
            .alert("Error", isPresented: $linkFormViewModel.savingErrorAlert) {
                Button {
                    linkFormViewModel.savingErrorAlert = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text(linkFormViewModel.savingErrorMessage)
            }
        }
        .onChange(of: linkFormViewModel.sheetOpen) {
            if linkFormViewModel.sheetOpen == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    linkFormViewModel.reset()
                }
            }
        }
    }
}
