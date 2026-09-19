import SwiftUI
import CustomAlert
import AlertToast

struct RootView: View {
    @State private var rootViewModel: RootViewModel
    
    init() {
        _rootViewModel = State(initialValue: RootViewModel())
    }
       
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    @AppStorage(StorageKeys.useSoftEdgeEffect, store: UserDefaults.shared) private var useSoftEdgeEffect: Bool = false
    
    @FetchRequest(
        entity: ServerInstance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<ServerInstance>
        
    var body: some View {
        Group {
            if !instances.isEmpty && rootViewModel.apiClientInstance != nil {
                ActiveServerView()
            }
            else {
                Text(verbatim: "")
            }
        }
        .toast(isPresenting: $rootViewModel.toastPresenting, duration: 2, tapToDismiss: true) {
            rootViewModel.toast ?? AlertToast(type: .regular)
        }
        .customAlert(isPresented: $rootViewModel.showingProgressIndicator, content: {
            ProgressView()
                .controlSize(.extraLarge)
                .foregroundStyle(.primary)
        })
        .onAppear {
            rootViewModel.initApiClientInstance()
            requestAppReview()
        }
        .onReceive(NotificationCenter.default.publisher(for: .repositoriesDidReset)) { _ in
            rootViewModel = RootViewModel()
            rootViewModel.showOnboarding = true
        }
        .fullScreenCover(isPresented: $rootViewModel.showOnboarding, content: {
            OnboardingView()
        })
        .environment(rootViewModel)
        .fontDesign(.rounded)
        .condition(transform: { view in
            if #available(iOS 27, *) {
                view.scrollEdgeEffectStyle(useSoftEdgeEffect == true ? .soft : .automatic, for: .all)
            }
            else { view }
        })
        .preferredColorScheme(getColorScheme(theme: theme))
    }
}

fileprivate struct ActiveServerView: View {
    @Environment(RootViewModel.self) private var rootViewModel

    var body: some View {
        
        Group {
            @Bindable var rootViewModel = rootViewModel
            if #available(iOS 26.0, *) {
                TabView(selection: $rootViewModel.selectedNavigationTab) {
                    Tab(value: .home) {
                        DashboardView()
                    } label: {
                        Label("Dashboard", systemImage: "house.fill")
                    }
                    Tab(value: .catalog) {
                        ElementsView()
                    } label: {
                        Label("Elements", systemImage: "books.vertical.fill")
                    }
                    if #available(iOS 27.0, *) {
                        Tab(value: .search, role: .prominent) {
                            SearchView()
                        } label: {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    } else {
                        Tab(value: .search, role: .search) {
                            SearchView()
                        } label: {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    }
                    Tab(value: .settings) {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            else {
                TabView(selection: $rootViewModel.selectedNavigationTab) {
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "house.fill")
                        }
                        .tag(Enums.TabViewTabs.home)
                    ElementsView()
                        .tabItem {
                            Label("Elements", systemImage: "books.vertical.fill")
                        }
                        .tag(Enums.TabViewTabs.catalog)
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(Enums.TabViewTabs.search)
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(Enums.TabViewTabs.settings)
                }
            }
        }
        .task {
            rootViewModel.fetchCollections()
            rootViewModel.fetchUserData()
        }
    }
}
