import SwiftUI

struct MenuBarTagsPickerView: View {
    var goBack: () -> Void
    
    @State private var menuBarTagsPickerViewModel: MenuBarTagsPickerViewModel
    
    init(goBack: @escaping () -> Void) {
        self.goBack = goBack
        _menuBarTagsPickerViewModel = State(initialValue: MenuBarTagsPickerViewModel())
    }
    
    @Environment(MenuBarFormViewModel.self) private var menuBarFormViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .padding(.horizontal, 2)
                        .padding(.vertical, 8)
                }
                Spacer()
                    .frame(width: 12)
                Text("Tags")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            Form {
                
            }
            .formStyle(GroupedFormStyle())
        }
    }
}
