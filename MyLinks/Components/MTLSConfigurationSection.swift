import SwiftUI
import UniformTypeIdentifiers

struct MTLSConfigurationSection: View {
    @Bindable var onboardingViewModel: OnboardingViewModel

    @State private var showingFileImporter = false

    private static let allowedContentTypes: [UTType] = [
        UTType(filenameExtension: "p12") ?? .data,
        UTType(filenameExtension: "pfx") ?? .data
    ]

    var body: some View {
        Section {
            Toggle(isOn: $onboardingViewModel.mtlsEnabled) {
                Text("Mutual TLS (mTLS)")
            }
            .onChange(of: onboardingViewModel.mtlsEnabled) { _, enabled in
                if !enabled {
                    onboardingViewModel.resetMtls()
                }
            }

            if onboardingViewModel.mtlsEnabled {
                if let fileName = onboardingViewModel.mtlsFileName {
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundStyle(.secondary)
                        Text(fileName)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button("Replace") {
                            showingFileImporter = true
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.small)
                        Button("Remove") {
                            onboardingViewModel.clearMtlsFile()
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.small)
                        .foregroundStyle(.red)
                    }
                } else {
                    Button("Select certificate file") {
                        showingFileImporter = true
                    }
                }

                SecureField("Certificate password (optional)", text: $onboardingViewModel.mtlsPassword)
            }
        } header: {
            Text("Client certificate")
        } footer: {
            if onboardingViewModel.mtlsEnabled {
                Text("Select a .p12 or .pfx file containing your client certificate and private key.")
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: Self.allowedContentTypes,
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            // Read the data while the security-scoped URL is accessible
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let data = try Data(contentsOf: url)
                onboardingViewModel.mtlsFileData = data
                onboardingViewModel.mtlsFileName = url.lastPathComponent
            } catch {
                onboardingViewModel.invalidValuesMessage = String(localized: "Failed to load file")
                onboardingViewModel.invalidValuesAlert = true
            }

        case .failure(let error):
            // Cancellation by the user produces a non-error; real errors are shown
            let nsError = error as NSError
            if nsError.domain != NSCocoaErrorDomain || nsError.code != NSUserCancelledError {
                onboardingViewModel.invalidValuesMessage = String(localized: "Failed to load file")
                onboardingViewModel.invalidValuesAlert = true
            }
        }
    }
}
