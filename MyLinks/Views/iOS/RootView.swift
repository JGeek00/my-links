import SwiftUI
import CustomAlert
import AlertToast

struct RootView: View {
    @State private var onboardingViewModel: OnboardingViewModel
    @State private var rootViewModel: RootViewModel
    
    init() {
        _onboardingViewModel = State(initialValue: OnboardingViewModel())
        _rootViewModel = State(initialValue: RootViewModel())
    }
       
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @FetchRequest(
        entity: ServerInstance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<ServerInstance>
        
    var body: some View {
        Group {
            if !instances.isEmpty && rootViewModel.apiClientInstance != nil {
                ActiveServerView()
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
        .fontDesign(.rounded)
        .preferredColorScheme(getColorScheme(theme: theme))
        .onAppear(perform: {
            onboardingViewModel.checkInstance()
            requestAppReview()
        })
        .fullScreenCover(isPresented: $onboardingViewModel.showOnboarding, content: {
            OnboardingView()
        })
        .onChange(of: onboardingViewModel.showOnboarding) {
            onboardingViewModel.reset()
        }
        .environment(rootViewModel)
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
                    Tab(value: .search, role: .search) {
                        SearchView()
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
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
            await rootViewModel.fetchCollections()
        }
//        .customAlert(isPresented: $linkManagerProvider.processing, content: {
//            HStack {
//                ProgressView()
//                    .tint(Color.gray)
//                    .font(.system(size: 20))
//                Spacer()
//                    .frame(width: 12)
//                Text("Processing...")
//                    .fontWeight(.medium)
//                    .font(.system(size: 16))
//            }
//            .padding(.horizontal)
//        })
//        .alert("Error", isPresented: $linkManagerProvider.errorAlert) {
//            Button("Close", role: .cancel) {
//                linkManagerProvider.errorAlert.toggle()
//            }
//        } message: {
//            Text(linkManagerProvider.errorMessage)
//        }
    }
}
