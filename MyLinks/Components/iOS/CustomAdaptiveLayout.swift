
import SwiftUI

enum AdaptiveLayoutMode: String {
    case arrangementView = "Arrangement View"
    case splitView = "Split View"
}

struct CustomAdaptiveLayout<MainView: View, SecondaryView: View>: View {

    @ViewBuilder let mainView: (_ mode: AdaptiveLayoutMode) -> MainView
    @ViewBuilder let secondaryView: (_ mode: AdaptiveLayoutMode) -> SecondaryView

    let splitViewPreferredColumn: Binding<NavigationSplitViewColumn>

    init(
        splitViewPreferredColumn: Binding<NavigationSplitViewColumn>,
        @ViewBuilder mainView: @escaping (_ mode: AdaptiveLayoutMode) -> MainView,
        @ViewBuilder secondaryView: @escaping (_ mode: AdaptiveLayoutMode) -> SecondaryView
    ) {
        self.mainView = mainView
        self.secondaryView = secondaryView
        self.splitViewPreferredColumn = splitViewPreferredColumn
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        GeometryReader { proxy in
            if #available(iOS 27.1, *) {
                let hasFold = !proxy.reservedRegions(
                    kind: .division,
                    options: .includeInactive
                ).isEmpty

                if hasFold {
                    arrangementView()
                } else {
                    splitView(width: proxy.size.width)
                }
            } else {
                splitView(width: proxy.size.width)
            }
        }
    }

    @ViewBuilder
    private func arrangementView() -> some View {
        if #available(iOS 27.1, *) {
            ArrangementView {
                mainView(.arrangementView)
            } secondary: {
                secondaryView(.arrangementView)
            }
            .arrangementViewStyle(.split)
            .background(Color.listBackground)

        }
    }

    @ViewBuilder
    private func splitView(width: CGFloat) -> some View {
        NavigationSplitView(
            preferredCompactColumn: splitViewPreferredColumn
        ) {
            mainView(.splitView)
                .navigationSplitViewColumnWidth(min: width / 3, ideal: width / 3, max: width / 3)
        } detail: {
            secondaryView(.splitView)
        }
        .toolbar(
            horizontalSizeClass == .compact &&
            splitViewPreferredColumn.wrappedValue == .detail
                ? .hidden
                : .visible,
            for: .tabBar
        )
        .background(Color.listBackground)
    }
}

#Preview("CustomAdaptiveLayout") {
    PreviewContainer()
}

private struct PreviewContainer: View {

    @State private var preferredColumn: NavigationSplitViewColumn = .sidebar

    var body: some View {
        CustomAdaptiveLayout(splitViewPreferredColumn: $preferredColumn) { mode in
            List {
                ForEach(1...20, id: \.self) { index in
                    Label {
                        Text(verbatim: "Item \(index)")
                    } icon: {
                        Image(systemName: "folder")
                    }
                }
            }
            .navigationTitle(Text(verbatim: "Principal"))
        } secondaryView: { mode in
            NavigationStack {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.largeTitle)

                    Text(verbatim: "Secondary view")
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle(Text(verbatim: "Detail"))
            }
        }
    }
}

#Preview("CustomAdaptiveLayout Interactive") {
    PreviewInteractiveContainer()
}

private struct PreviewInteractiveContainer: View {

    @State private var preferredColumn: NavigationSplitViewColumn = .sidebar

    var body: some View {
        VStack {
            Picker(selection: $preferredColumn) {
                Text(verbatim: "Sidebar").tag(NavigationSplitViewColumn.sidebar)
                Text(verbatim: "Detail").tag(NavigationSplitViewColumn.detail)
            } label: {
                Text(verbatim: "Column")
            }
            .pickerStyle(.segmented)
            .padding()

            CustomAdaptiveLayout(splitViewPreferredColumn: $preferredColumn) { mode in
                List(1...10, id: \.self) { index in
                    Text(verbatim: "Item \(index)")
               }
            } secondaryView: { mode in
                Text(verbatim: "Detail")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
