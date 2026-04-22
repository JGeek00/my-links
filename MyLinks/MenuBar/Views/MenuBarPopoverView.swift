import SwiftUI

fileprivate enum PopoverNavigation: String {
    case tags
}

struct MenuBarPopoverView: View {
    @State private var menuBarFormViewModel: MenuBarFormViewModel
    
    init() {
        _menuBarFormViewModel = State(initialValue: MenuBarFormViewModel())
    }
    
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var popoverState: PopoverState
    
    @State private var text = ""
    @FocusState private var focus: Bool
    
    var body: some View {
        if popoverState.isPopoverOpen {
            PopoverContent()
                .environment(menuBarFormViewModel)
                .frame(width: 400, height: 400)
                .onAppear {
                    menuBarFormViewModel = MenuBarFormViewModel()
                    Task { await menuBarFormViewModel.loadData() }
                }
        }
        else {
            VStack {
                TextField("", text: $text)
                    .focused($focus)
                    .opacity(0)
            }
            .frame(width: 400, height: 400)
            .onAppear {
                focus = false
            }
        }
    }
}

struct PopoverContent: View {
    @Environment(MenuBarFormViewModel.self) private var menuBarFormViewModel
    @EnvironmentObject private var popoverState: PopoverState
    
    @Environment(\.openWindow) private var openWindow

    @State private var path = NavigationPath()
    
    func openMainWindow() {
        openWindow(id: WindowIds.main)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.mainWindow?.makeKeyAndOrderFront(nil)
    }
    
    var body: some View {
        @Bindable var menuBarFormViewModel = menuBarFormViewModel
        NavigationStack(path: $path) {
            VStack {
                if menuBarFormViewModel.serverInstanceAvailable == true {
                    Group {
                        if menuBarFormViewModel.loading == true {
                            ProgressView()
                        }
                        else if menuBarFormViewModel.loadError == true {
                            ContentUnavailableView("Cannot connect to the server", systemImage: "exclamationmark.circle", description: Text("Check your internet connection and try again."))
                            Spacer()
                                .frame(height: 30)
                            Button {
                                openMainWindow()
                            } label: {
                                Text("Open My Links")
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
                                    Text("Open My Links")
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
                                                Text(item.name)
                                                    .tag(item.id)
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
                                    menuBarFormViewModel.onSave()
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
                                Text("An error occurred while creating the link. Please try again.")
                            }
                            .alert("Success", isPresented: $menuBarFormViewModel.linkCreatedAlert) {
                                Button {
                                    popoverState.isPopoverOpen = false
                                } label: {
                                    Text("Close")
                                }
                            } message: {
                                Text("Link created successfully.")
                            }
                        }
                    }
                    .task {
                        await menuBarFormViewModel.loadData()
                    }
                }
                else {
                    ContentUnavailableView("Server unavailable", systemImage: "server.rack", description: Text("Open the app to create a connection to a server."))
                }
            }
            .navigationDestination(for: PopoverNavigation.self) { _ in
                MenuBarTagsPickerView(tags: menuBarFormViewModel.selectedTags) {
                    path.removeLast()
                }
            }
        }
    }
}

