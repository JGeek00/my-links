import SwiftUI
import UIKit

// MARK: - Public View
struct TagsTextField: View {
    @Binding var tags: [String]
    @Binding var currentTextInput: String
    var onRemoveTag: (String) -> Void

    private func addOrMoveTag(_ newTag: String) {
        let trimmed = newTag.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let idx = tags.firstIndex(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            let existing = tags.remove(at: idx)
            tags.append(existing)
        } else {
            tags.append(trimmed)
        }
    }

    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(Array(tags.enumerated()), id: \.offset) { _, tag in
                TagChip(label: tag)
                    .onTapGesture {
                        onRemoveTag(tag)
                    }
            }
            BackspaceTextField(
                text: $currentTextInput,
                placeholder: "\(String(localized: "Tags"))...",
                onCommitTag: { text in
                        let trimmed = text.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            addOrMoveTag(trimmed)
                            currentTextInput = ""
                        }
                },
                onDeleteBackwardWhenEmpty: {
                    guard !tags.isEmpty else { return }
                    let last = tags.removeLast()
                    currentTextInput = last
                }
            )
            .frame(minWidth: 80, maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

// MARK: - Tag Chip
fileprivate struct TagChip: View {
    let label: String
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Color.foreground.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - UITextField wrapper that intercepts deleteBackward
fileprivate struct BackspaceTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onCommitTag: (String) -> Void
    var onDeleteBackwardWhenEmpty: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> _BackspaceUITextField {
        let tf = _BackspaceUITextField()
        tf.delegate = context.coordinator
        tf.placeholder = placeholder
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.borderStyle = .none
        tf.font = UIFont.preferredFont(forTextStyle: .body)
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf.onDeleteBackwardWhenEmpty = onDeleteBackwardWhenEmpty
        tf.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return tf
    }

    func updateUIView(_ uiView: _BackspaceUITextField, context: Context) {
        if uiView.text != text { uiView.text = text }
        uiView.onDeleteBackwardWhenEmpty = onDeleteBackwardWhenEmpty
        if uiView.isFirstResponder {
            let end = uiView.endOfDocument
            uiView.selectedTextRange = uiView.textRange(from: end, to: end)
        }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: BackspaceTextField
        init(_ parent: BackspaceTextField) { self.parent = parent }

        @objc func textChanged(_ tf: UITextField) {
            let current = tf.text ?? ""
            if current.hasSuffix(",") {
                let trimmed = String(current.dropLast()).trimmingCharacters(in: .whitespaces)
                parent.text = ""
                tf.text = ""
                if !trimmed.isEmpty { parent.onCommitTag(trimmed) }
                return
            }
            parent.text = current
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            let trimmed = (textField.text ?? "").trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                parent.onCommitTag(trimmed)
                textField.text = ""
                parent.text = ""
            }
            return false
        }
    }
}

// MARK: - Custom UITextField subclass to catch deleteBackward
fileprivate final class _BackspaceUITextField: UITextField {
    var onDeleteBackwardWhenEmpty: (() -> Void)?

    override func deleteBackward() {
        if (text ?? "").isEmpty {
            onDeleteBackwardWhenEmpty?()
        } else {
            super.deleteBackward()
        }
    }
}

// MARK: - Flow Layout
fileprivate struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: maxWidth, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var tags: [String] = []
    @Previewable @State var currentTextInput: String = ""
    @Previewable @State var suggestedTags: [String] = []

    let availableTags = ["Apple", "Google", "Amazon", "Microsoft", "Meta", "Tesla", "Netflix", "NVIDIA", "Adobe", "Salesforce"]
    
    List {
        Section {
            TagsTextField(tags: $tags, currentTextInput: $currentTextInput) { removedTag in
                tags = tags.filter() { $0 != removedTag }
            }
            .onChange(of: currentTextInput, initial: false) { _, newValue in
                suggestedTags = newValue.isEmpty ? [] : availableTags.filter {
                    $0.lowercased().contains(newValue.lowercased())
                }
            }
        } footer: {
            Text("- Separe each tag by a comma (,) or by hitting enter.\n- Tap on an already added tag to remove it.\n- Write text to see suggestions.\n- Tap on a suggestion to add a tag.\n\n")
        }
        if !suggestedTags.isEmpty {
            Section("Suggestions") {
                ForEach(suggestedTags, id: \.self) { tag in
                    Text(tag)
                        .onTapGesture {
                            let trimmed = tag.trimmingCharacters(in: .whitespaces)
                            if let idx = tags.firstIndex(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
                                let existing = tags.remove(at: idx)
                                tags.append(existing)
                            } else {
                                tags.append(trimmed)
                            }
                            currentTextInput = ""
                            suggestedTags = []
                        }
                }
            }
            .animation(.default, value: suggestedTags)
        }
    }
    .animation(.default, value: suggestedTags)
}
