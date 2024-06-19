import SwiftUI

struct TagsPickerView: View {
    @EnvironmentObject private var tagsProvider: TagsProvider
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    
    var body: some View {
        let filtered = tagsProvider.data?.response?.filter() { $0.name != nil && $0.id != nil }
        List(filtered ?? [], id: \.self) { item in
            Button {
                if linkFormViewModel.selectedTags.contains(item.name!) {
                    linkFormViewModel.selectedTags = linkFormViewModel.selectedTags.filter() { $0 != item.name! }
                }
                else {
                    linkFormViewModel.selectedTags.append(item.name!)
                }
            } label: {
                HStack {
                    Text(item.name!)
                        .foregroundStyle(Color.foreground)
                    Spacer()
                    if linkFormViewModel.selectedTags.contains(item.name!) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
}
