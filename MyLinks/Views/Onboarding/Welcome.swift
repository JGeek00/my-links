import SwiftUI

struct Welcome: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Image("AppIconImage")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                Spacer()
                    .frame(height: 24)
                Text("Welcome to MyLinks")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .padding(.bottom, 12)
                Text("Your application to manage your Linkwarden links")
                    .fontWeight(.medium)
                    .font(.system(size: 30))
                    .foregroundStyle(Color.gray)
            }
            .padding(24)
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation(.default) {
                        onboardingViewModel.selectedTab = 1
                    }
                } label: {
                    Text("Get started")
                        .fontWeight(.medium)
                        .font(.system(size: 20))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .padding()
                Spacer()
            }
            .padding(0)
        }
        .padding(0)
        .fontDesign(.rounded)
    }
}
