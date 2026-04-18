import SwiftUI

struct ServerSelection: View {
    @Environment(OnboardingViewModel.self) private var onboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
            Spacer()
                .frame(height: 24)
            Text("To begin, select the place where your data is stored")
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .padding(.bottom, 12)
            Spacer()
            VStack(alignment: .leading) {
                Button {
                    withAnimation(.default) {
                        onboardingViewModel.hostingMode = .cloud
                        onboardingViewModel.selectedTab = 2
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Cloud")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .padding(.bottom, 2)
                            Text("If your data is stored on Linkwarden's servers")
                                .font(.system(size: 14))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.gray)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                Divider()
                    .padding(.vertical, 6)
                Button {
                    withAnimation(.default) {
                        onboardingViewModel.hostingMode = .selfhosted
                        onboardingViewModel.selectedTab = 2
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Self hosted")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .padding(.bottom, 2)
                            Text("If your data is stored on your own server")
                                .font(.system(size: 14))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.gray)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(12)
            .background(Color.listItemBackground)
            .cornerRadius(24)
            Spacer()
        }
        .padding(24)
    }
}
