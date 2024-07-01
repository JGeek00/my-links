import SwiftUI

private enum PopoverNavigation: String {
    case tags
}

struct PopoverView: View {

    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var popoverState: PopoverState
    
    @State private var text = ""
    @FocusState private var focused: Bool
    
    var body: some View {
        if popoverState.isPopoverOpen == true {
            PopoverContent()
                .environmentObject(MenuBarFormViewModel())
                .frame(width: 400, height: 400)
        }
        else {
            VStack {
                TextField("", text: $text)
                    .focused($focused)
                    .opacity(0)
            }
            .frame(width: 400, height: 400)
            .onAppear {
                focused = true
            }
        }
    }
}

struct PopoverContent: View {
    @EnvironmentObject private var menuBarFormViewModel: MenuBarFormViewModel
    @EnvironmentObject private var popoverState: PopoverState
    
    @Environment(\.openWindow) private var openWindow

    @State private var path = NavigationPath()
    
    func openMainWindow() {
        openWindow(id: WindowIds.main)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if menuBarFormViewModel.apiClient != nil {
                    if menuBarFormViewModel.loading == true {
                        ProgressView()
                    }
                    else if menuBarFormViewModel.error == true {
                        ContentUnavailableView("Cannot connect to the server", systemImage: "exclamationmark.circle", description: Text("Check your internet connection and try again."))
                        Spacer()
                            .frame(height: 30)
                        Button {
                            openMainWindow()
                        } label: {
                            Text("Open MyLinks")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                        }
                    }
                    else {
                        HStack {
                            Text("New link")
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                            Spacer()
                            Button {
                                openMainWindow()
                            } label: {
                                Text("Open MyLinks")
                            }
                        }
                        .padding(.top, 30)
                        .padding(.horizontal, 24)
                        Form {
                            Section {
                                TextField("URL", text: $menuBarFormViewModel.url)
                                    .autocorrectionDisabled()
                            }
                            Section {
                                TextField("Name", text: $menuBarFormViewModel.name)
                                TextField("Description", text: $menuBarFormViewModel.description, axis: .vertical)
                            }
                            if !menuBarFormViewModel.collections.isEmpty {
                                Section {
                                    Picker("Collection", selection: $menuBarFormViewModel.collection) {
                                        ForEach(menuBarFormViewModel.collections, id: \.self) { item in
                                            Text(item.name!)
                                                .tag(item.id!)
                                        }
                                    }
                                }
                            }
                            Button {
                                path.append(PopoverNavigation.tags)
                            } label: {
                                HStack {
                                    Text("Tags")
                                    Spacer()
                                        .frame(width: 12)
                                    if menuBarFormViewModel.selectedTags.isEmpty == false {
                                        Text(String(menuBarFormViewModel.selectedTags.count))
                                            .font(.system(size: 10))
                                            .fontWeight(.semibold)
                                            .padding(6)
                                            .foregroundStyle(Color.white)
                                            .background(Color.accentColor)
                                            .clipShape(Circle())
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .formStyle(GroupedFormStyle())
                        HStack {
                            ProgressView()
                                .controlSize(.small)
                                .opacity(menuBarFormViewModel.saving ? 1 : 0)
                            Spacer()
                            Button {
                                menuBarFormViewModel.createLink()
                            } label: {
                                Text("Create")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                            .disabled(menuBarFormViewModel.saving)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .alert("Validation error", isPresented: $menuBarFormViewModel.validationErrorAlert) {
                            Button {
                                menuBarFormViewModel.validationErrorAlert = false
                            } label: {
                                Text("Close")
                            }
                        } message: {
                            Text(menuBarFormViewModel.validationErrorMessage)
                        }
                        .alert("Error", isPresented: $menuBarFormViewModel.savingErrorAlert) {
                            Button {
                                menuBarFormViewModel.savingErrorAlert = false
                            } label: {
                                Text("Close")
                            }
                        } message: {
                            Text(menuBarFormViewModel.savingErrorMessage)
                        }
                        .alert("Success", isPresented: $menuBarFormViewModel.linkCreated) {
                            Button {
                                menuBarFormViewModel.linkCreated = false
                            } label: {
                                Text("Close")
                            }
                        } message: {
                            Text("Link created successfully.")
                        }
                    }
                }
                else {
                    ContentUnavailableView("Server unavailable", systemImage: "server.rack", description: Text("Open the app to create a connection to a server."))
                }
            }
            .navigationDestination(for: PopoverNavigation.self) { _ in
                TagsList {
                    path.removeLast()
                }
            }
        }
    }
}

private struct TagsList: View {
    var goBack: () -> Void
    
    init(goBack: @escaping () -> Void) {
        self.goBack = goBack
    }
    
    @EnvironmentObject private var menuBarFormViewModel: MenuBarFormViewModel
    
    @State private var addTagAlert = false
    @State private var newTagName = ""
    
    var body: some View {
        let tags = (menuBarFormViewModel.tags.map() { $0.name! }) + menuBarFormViewModel.localTags
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
                Spacer()
                Button {
                    addTagAlert = true
                } label: {
                    Image(systemName: "plus")
                        .padding(.horizontal, 2)
                        .padding(.vertical, 8)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            Form {
                ForEach(tags, id: \.self) { item in
                    let contains = menuBarFormViewModel.selectedTags.contains(item)
                    Button {
                        if menuBarFormViewModel.selectedTags.contains(item) {
                            menuBarFormViewModel.selectedTags = menuBarFormViewModel.selectedTags.filter() { $0 != item }
                        }
                        else {
                            menuBarFormViewModel.selectedTags.append(item)
                        }
                    } label: {
                        HStack {
                            Text(item)
                            Spacer()
                            Image(systemName: "checkmark")
                                .opacity(contains ? 1 : 0)
                                .animation(.default, value: contains)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .formStyle(GroupedFormStyle())
        }
        .alert("Add tag", isPresented: $addTagAlert) {
            Button("Cancel", role: .cancel) {
                addTagAlert.toggle()
            }
            Button("Save") {
                menuBarFormViewModel.localTags.append(newTagName)
                menuBarFormViewModel.selectedTags.append(newTagName)
            }
            TextField("Tag name", text: $newTagName)
        }
    }
}
