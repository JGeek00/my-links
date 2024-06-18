import SwiftUI

struct ConnectionForm: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        if onboardingViewModel.hostingMode == nil {
            VStack {
                Spacer()
                Button("Back to hosting mode selection") {
                    withAnimation(.default) {
                        onboardingViewModel.selectedTab = 1
                    }
                }
                Spacer()
            }
        }
        else {
            List {
                Section {
                    VStack(alignment: .leading) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 60))
                        Spacer()
                            .frame(height: 24)
                        Text("Setup the server connection")
                            .fontWeight(.semibold)
                            .font(.system(size: 30))
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                if onboardingViewModel.hostingMode == .selfhosted {
                    Section("Server route") {
                        Picker("Connection method", selection: $onboardingViewModel.connectionMethod) {
                            Text("HTTP")
                                .tag(Enums.ConnectionMethod.http)
                            Text("HTTPS")
                                .tag(Enums.ConnectionMethod.https)
                        }
                        TextField("IP address or domain", text: $onboardingViewModel.ipDomain)
                        TextField("Port", text: $onboardingViewModel.port)
                        TextField("Path", text: $onboardingViewModel.path)
                    }
                }
                Section("Authentication") {
                    TextField("Token", text: $onboardingViewModel.token)
                }
                Section {
                    Button {
                        
                    } label: {
                        Spacer()
                        Text("Connect")
                            .fontWeight(.semibold)
                            .font(.system(size: 18))
                        Spacer()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(.vertical, 6)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}
