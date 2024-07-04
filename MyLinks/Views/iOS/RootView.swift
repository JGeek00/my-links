import SwiftUI
import CustomAlert
import AlertToast

struct RootView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var toastProvider: ToastProvider
    
    let collectionsProvider = CollectionsProvider.shared
    let tagsProvider = TagsProvider.shared
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @FetchRequest(
        entity: ServerInstance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<ServerInstance>
    
    var body: some View {
        Group {
            if !instances.isEmpty && apiClientProvider.instance != nil {
                TabView {
                    DashboardView()
                        .environmentObject(DashboardViewModel.shared)
                        .tabItem {
                            Label("Dashboard", systemImage: "house.fill")
                        }
                    LinksView()
                        .tabItem {
                            Label("Links", systemImage: "link")
                        }
                    CollectionsView()
                        .tabItem {
                            Label("Collections", systemImage: "folder")
                        }
                    TagsView()
                        .tabItem {
                            Label("Tags", systemImage: "tag")
                        }
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
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
