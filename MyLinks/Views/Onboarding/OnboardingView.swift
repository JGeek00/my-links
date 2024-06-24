import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if horizontalSizeClass == .compact {
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
        else {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Group {
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
                        .padding()
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .fontDesign(.rounded)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    }
                    .frame(maxWidth: 600, maxHeight: 800)
                    .cornerRadius(12)
                    Spacer()
                }
                Spacer()
            }
            .background(Color.listBackground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
    }
}
