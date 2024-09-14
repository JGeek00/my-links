import SwiftUI

struct GeneralSettings: View {
    init() {}
    
    @State var disconnectAlert = false
    @State var collectionsViewModeSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        collectionsViewModeSheet = true
                    } label: {
                        HStack {
                            Text("Collections view mode")
                                .foregroundStyle(Color.foreground)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.navigationLinkArrow)
                                .fontWeight(.semibold)
                                .font(.system(size: 14))
                        }
                    }
                }
                
                Section("Server") {
                    Button {
                        disconnectAlert.toggle()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "xmark", iconColor: .red, textColor: .red, label: "Disconnect from server")
                    }
                    .alert("Disconnect from server", isPresented: $disconnectAlert) {
                        Button("Cancel", role: .cancel) {
                            disconnectAlert.toggle()
                        }
                        Button("Disconnect", role: .destructive) {
                            ApiClientProvider.shared.destroy()
                        }
                    } message: {
                        Text("You will have to establish a connection again.")
                    }
                }
            }
            .navigationTitle("General settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $collectionsViewModeSheet) {
                CollectionViewModeSheet {
                    collectionsViewModeSheet = false
                }
                .presentationDetents([.fraction(0.5)])
            }
        }
    }
}
