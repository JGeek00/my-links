import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        TabView(selection: $onboardingViewModel.selectedTab) {
            Welcome()
                .tag(0)
                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
            ServerSelection()
                .tag(1)
                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
            ConnectionForm()
                .tag(2)
                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
        }
        .background(Color.listBackground)
        .fontDesign(.rounded)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
    }
}
