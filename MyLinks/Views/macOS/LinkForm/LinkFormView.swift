import SwiftUI

struct LinkFormView: View {
    var mode: Enums.LinkFormItem
    var onClose: () -> Void
    var onSuccess: (Link, Enums.LinkFormAction) -> Void
    
    @State private var linkFormViewModel: LinkFormViewModel
    
    init(mode: Enums.LinkFormItem, link: Link? = nil, defaultCollectionId: Int? = nil, onClose: @escaping () -> Void, onSuccess: @escaping (Link, Enums.LinkFormAction) -> Void) {
        self.mode = mode
        self.onClose = onClose
        self.onSuccess = onSuccess
        _linkFormViewModel = State(wrappedValue: LinkFormViewModel(link: link, defaultCollectionId: defaultCollectionId))
    }
        
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
                            .disabled(linkFormViewModel.editingLink != nil)
                    }
                case .file:
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
                                    }
                                }
                                Spacer()
                                    .frame(height: 24)
                                Button {
                                    showFilePicker = true
                                } label: {
                                    Text(linkFormViewModel.selectedFileUrl != nil ? "Replace selected file (up to 10 MB)" : "Pick a file (up to 10 MB)")
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
                Section {
                    TextField("Name", text: $linkFormViewModel.name)
                    TextField("Description", text: $linkFormViewModel.description, axis: .vertical)
                }
                Section {
                    if !linkFormViewModel.availableCollections.isEmpty {
                        Picker("Collection", selection: $linkFormViewModel.collection) {
                            ForEach(linkFormViewModel.availableCollections, id: \.self) { item in
                                Text(item.name)
                                    .tag(item.id)
                            }
                        }
                    }
                    NavigationLink {
                        TagsPickerView(existingTags: linkFormViewModel.selectedTags)
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
            .frame(minHeight: 250)
            .formStyle(GroupedFormStyle())
            .disabled(linkFormViewModel.saving)
            .navigationTitle(linkFormViewModel.editingLink != nil ? "Edit link" : "New link")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onClose()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        linkFormViewModel.onSave(mode: mode) { newLink in
                            onSuccess(newLink, linkFormViewModel.editingLink != nil ? .edit : .create)
                        }
                    } label: {
                        Text("Save")
                    }
                    .disabled(linkFormViewModel.saving)
                }
                if linkFormViewModel.saving {
                    ToolbarItem(placement: .destructiveAction) {
                        ProgressView()
                            .controlSize(.small)
                    }
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
        .padding()
        .frame(width: 500, height: mode == .file ? 500 : 400)
        .environment(linkFormViewModel)
    }
}
