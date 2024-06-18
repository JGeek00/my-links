import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        SummaryEntry(icon: "link", label: "Links", value: 10, color: Color.green)
                            .frame(maxWidth: .infinity)
                        Divider()
                            .padding(.vertical, 6)
                        SummaryEntry(icon: "folder.fill", label: "Collections", value: 10, color: Color.blue)
                            .frame(maxWidth: .infinity)
                        Divider()
                            .padding(.vertical, 6)
                        SummaryEntry(icon: "tag.fill", label: "Tags", value: 10, color: Color.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

private struct SummaryEntry: View {
    var icon: String
    var label: String
    var value: Int
    var color: Color
    
    var body: some View {
        Section {
            VStack {
                Image(systemName: icon)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .foregroundStyle(Color.white)
                    .cornerRadius(8)
                Spacer()
                    .frame(height: 6)
                Text(label)
                Spacer()
                    .frame(height: 6)
                Text(String(value))
                    .fontWeight(.semibold)
            }
        }
    }
}
