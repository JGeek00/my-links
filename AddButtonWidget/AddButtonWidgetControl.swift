import AppIntents
import SwiftUI
import WidgetKit

struct AddButtonWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.jgeek00.MyLinks.AddButtonWidget") {
            ControlWidgetButton(action: OpenURLIntent(URL(string: "mylinks://new-link")!)) {
                Label("Add a link", systemImage: "plus")
            }
        }
        .displayName("Add a link")
        .description("Creates a link on My Links app.")
    }
}
