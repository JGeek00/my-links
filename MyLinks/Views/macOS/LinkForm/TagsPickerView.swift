import SwiftUI

struct TagsPickerView: View {
    @State private var tagsPickerViewModel: TagsPickerViewModel
    
    init(existingTags: [String]) {
        _tagsPickerViewModel = State(initialValue: TagsPickerViewModel(existingTags: existingTags))
    }
    
    @Environment(LinkFormViewModel.self) private var linkFormViewModel

    var body: some View {
        @Bindable var linkFormViewModel = linkFormViewModel
        Group {
           
            
        }
        .navigationTitle("Tags")
        .background(Color.listBackground)
    }
}
