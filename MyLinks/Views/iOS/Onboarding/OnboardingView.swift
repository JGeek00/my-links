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
            .onAppear {
                  UIScrollView.appearance().isScrollEnabled = false
            }
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
                        .background(Color.listBackground)
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
            .background(colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [Color.init(hex: "156487"), Color.init(hex: "0A3345")]), startPoint: .top, endPoint: .bottom) : LinearGradient(gradient: Gradient(colors: [Color.init(hex: "38BDF7"), Color.init(hex: "277A9F")]), startPoint: .top, endPoint: .bottom))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .shadow(radius: 20)
        }
    }
}
