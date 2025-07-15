import SwiftUI
import CustomAlert
import AlertToast

struct RootView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var toastProvider: ToastProvider
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    let collectionsProvider = CollectionsProvider.shared
    let tagsProvider = TagsProvider.shared
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    @AppStorage(StorageKeys.useOldTabBar, store: UserDefaults.shared) private var useOldTabBar: Bool = false
    
    @FetchRequest(
        entity: ServerInstance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<ServerInstance>
    
    @Environment(\.horizontalSizeClass) var currentHorizontalSizeClass
    
    var body: some View {
        Group {
            if !instances.isEmpty && apiClientProvider.instance != nil {
                Group {
                    if #available(iOS 26.0, *) {
                        TabView {
                            Tab("Dashboard", systemImage: "house.fill") {
                                DashboardView()
                                    .environmentObject(DashboardViewModel.shared)
                                    .environment(\.horizontalSizeClass, currentHorizontalSizeClass)
                            }
                            Tab("Elements", systemImage: "books.vertical.fill") {
                               ElementsView()
                                    .environment(\.horizontalSizeClass, currentHorizontalSizeClass)
                            }
                            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                                SearchView()
                            }
                            Tab("Settings", systemImage: "gear") {
                                SettingsView()
                                    .environment(\.horizontalSizeClass, currentHorizontalSizeClass)
                            }
                        }
                        .searchable(text: $searchViewModel.searchFieldValue, isPresented: $searchViewModel.searchPresented)
                        .onSubmit(of: .search) {
                            searchViewModel.search()
                        }
                    }
                    else {
                        TabView {
                            DashboardView()
                                .environmentObject(DashboardViewModel.shared)
                                .tabItem {
                                    Label("Dashboard", systemImage: "house.fill")
                                }
                                .environment(\.horizontalSizeClass, currentHorizontalSizeClass)

                            ElementsView()
                                .tabItem {
                                    Label("Elements", systemImage: "books.vertical.fill")
                                }
                                .environment(\.horizontalSizeClass, currentHorizontalSizeClass)
                            SettingsView()
                                .tabItem {
                                    Label("Settings", systemImage: "gear")
                                }
                                .environment(\.horizontalSizeClass, currentHorizontalSizeClass)
                        }
                    }
                }
                .environment(\.horizontalSizeClass, useOldTabBar == true ? .compact : currentHorizontalSizeClass)
                .onAppear(perform: {
                    if collectionsProvider.data.isEmpty {
                        Task { await collectionsProvider.loadData() }
                    }
                    if tagsProvider.data.isEmpty {
                        Task { await tagsProvider.loadData() }
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
        .environmentObject(tagsProvider)
    }
}
