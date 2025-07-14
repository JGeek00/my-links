import SwiftUI

struct LinkFormView: View {
    var mode: Enums.LinkFormItem
    var onClose: () -> Void
    var onSuccess: (Link, Enums.LinkTaskCompleted) -> Void
    
    init(mode: Enums.LinkFormItem, onClose: @escaping () -> Void, onSuccess: @escaping (Link, Enums.LinkTaskCompleted) -> Void) {
        self.mode = mode
        self.onClose = onClose
        self.onSuccess = onSuccess
    }
    
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    @State private var showFilePicker = false
    @State private var fileTooBigAlert = false
    @State private var selectFileError = false
    
    var body: some View {
        NavigationStack {
            Form {
                switch mode {
                case .url:
                    Section {
                        TextField("URL", text: $linkFormViewModel.url)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .disabled(linkFormViewModel.editingLink != nil)
                    }
                case .file:
                    if linkFormViewModel.editingLink == nil {
                        Section {
                            HStack {
                                Spacer()
                                VStack(alignment: .center) {
                                    Image(systemName: linkFormViewModel.selectedFileUrl != nil ? "doc.fill" : "folder.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color.white)
                                        .frame(width: 50, height: 50)
                                        .background(.gray)
                                        .cornerRadius(6)
                                    Spacer()
                                        .frame(height: 24)
                                    Text(linkFormViewModel.selectedFileUrl != nil ? linkFormViewModel.selectedFileUrl!.lastPathComponent : String(localized: "No file selected"))
                                        .font(.system(size: 22))
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(Color.foreground)
                                        .animation(.easeOut, value: linkFormViewModel.selectedFileUrl)
                                    Group {
                                        if linkFormViewModel.selectedFileUrl != nil {
                                            Spacer()
                                                .frame(height: 12)
                                            Text(linkFormViewModel.selectedFileUrl!.fileSizeString)
                                                .font(.system(size: 14))
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color.listItemValue)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.listItemValue, lineWidth: 1)
                                                )
                                                .animation(.easeOut, value: linkFormViewModel.selectedFileUrl)
                                            Spacer()
                                                .frame(height: 12)
                                        }
                                    }
                                    Spacer()
                                        .frame(height: 12)
                                    Button {
                                        showFilePicker = true
                                    } label: {
                                        Text(linkFormViewModel.selectedFileUrl != nil ? "Replace selected file (up to 10 MB)" : "Pick a file (up to 10 MB)")
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .padding()
                                Spacer()
                            }
                            .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf, .jpeg, .png], allowsMultipleSelection: false, onCompletion: { results in
                                switch results {
                                case .success(let success):
                                    if let file = success.first {
                                        if file.startAccessingSecurityScopedResource() {
                                            // 10 MB on bytes
                                            if file.fileSize > 10485760 {
                                                fileTooBigAlert = true
                                                return
                                            }
                                            linkFormViewModel.setSelectedFileUrl(fileUrl: file)
                                        }
                                    }
                                case .failure:
                                    selectFileError = true
                                }
                            })
                        }
                    }
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
                                .tag(0)
                        }
                    }
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
            .disabled(linkFormViewModel.saving)
            .navigationTitle(linkFormViewModel.editingLink != nil ? "Edit link" : "New link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onClose()
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
                        linkFormViewModel.onSave(mode: mode) { newLink in
                            onSuccess(newLink, linkFormViewModel.editingLink != nil ? .edit : .create)
                        }
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
            .alert("File too big", isPresented: $fileTooBigAlert) {
                Button {
                    fileTooBigAlert = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text("The selected file is too big. The file size must be below 10 MB.")
            }
            .alert("Failed to load file", isPresented: $selectFileError) {
                Button {
                    selectFileError = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text("The selected file cannot be loaded on the app.")
            }
        }
    }
}
