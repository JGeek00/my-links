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
                }
                Section {
                    TextField("Name", text: $linkFormViewModel.name)
                    TextField("Description", text: $linkFormViewModel.description, axis: .vertical)
                }
                Section {
                    if collectionsProvider.data?.response != nil {
                        Picker("Collection", selection: $linkFormViewModel.collection) {
                            let filtered = collectionsProvider.data!.response!.filter() { $0.name != nil && $0.id != nil }
                            ForEach(filtered, id: \.self) { item in
                                Text(item.name!)
                                    .tag(item.id!)
                            }
                        }
                    }
                    if tagsProvider.data?.response != nil {
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
            .navigationTitle(linkFormViewModel.editingId != nil ? "Edit link" : "New link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        linkFormViewModel.sheetOpen.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.listItemValue)
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
        .onChange(of: linkFormViewModel.sheetOpen) { value in
            if value == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    linkFormViewModel.reset()
                }
            }
        }
    }
}
