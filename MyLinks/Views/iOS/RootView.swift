import SwiftUI
import CustomAlert
import AlertToast

struct RootView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var toastProvider: ToastProvider
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var navigationProvider: NavigationProvider
    
    let collectionsProvider = CollectionsProvider.shared
       
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @FetchRequest(
        entity: ServerInstance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<ServerInstance>
        
    var body: some View {
        Group {
            if !instances.isEmpty && apiClientProvider.instance != nil {
                Group {
                    if #available(iOS 26.0, *) {
                        TabView(selection: $navigationProvider.selectedNavigationTab) {
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
                        TabView(selection: $navigationProvider.selectedNavigationTab) {
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
                .onAppear(perform: {
                    if collectionsProvider.data.isEmpty {
                        Task { await collectionsProvider.loadData() }
                    }
                })
                .customAlert(isPresented: $linkManagerProvider.processing, content: {
                    HStack {
                        ProgressView()
                            .tint(Color.gray)
                            .font(.system(size: 20))
                        Spacer()
                            .frame(width: 12)
                        Text("Processing...")
                            .fontWeight(.medium)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal)
                })
                .alert("Error", isPresented: $linkManagerProvider.errorAlert) {
                    Button("Close", role: .cancel) {
                        linkManagerProvider.errorAlert.toggle()
                    }
                } message: {
                    Text(linkManagerProvider.errorMessage)
                }
            }
        }
        .toast(isPresenting: $toastProvider.presenting, duration: 2, tapToDismiss: true) {
            toastProvider.toast ?? AlertToast(type: .regular)
        }
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
        .environmentObject(collectionsProvider)
    }
}
