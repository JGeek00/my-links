import SwiftUI

struct CollectionViewModeSheet: View {
    var onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @AppStorage(StorageKeys.collectionViewMode, store: UserDefaults.shared) private var collectionViewMode: Enums.CollectionViewMode = .list
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                SelectableItem(
                    title: String(localized: "List view"),
                    subtitle: String(localized: "The subcategories and the links are displayed on a single list, with the subcategories at the top and the links under them."),
                    value: .list
                )
                Spacer()
                SelectableItem(
                    title: String(localized: "Tabs view"),
                    subtitle: String(localized: "The subcategories and the links are displayed on two different lists, with a tab system to switch between them."),
                    value: .tabs
                )
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
            }
            .background(Color.listBackground)
            .navigationTitle("Collections view mode")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    func SelectableItem(title: String, subtitle: String, value: Enums.CollectionViewMode) -> some View {
        Button {
            collectionViewMode = value
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                    Spacer()
                        .frame(height: 4)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.listItemValue)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.blue)
                    .font(.system(size: 20))
                    .opacity(collectionViewMode == value ? 1 : 0)
            }
            .padding()
            .contentShape(Rectangle())
        }
        .background(Color.listItemBackground)
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
                .opacity(collectionViewMode == value ? 1 : 0)
        )
        .animation(.easeOut, value: collectionViewMode)
        .buttonStyle(.plain)
    }
}
