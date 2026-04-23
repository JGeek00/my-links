import SwiftUI
import AppKit

// MARK: - Public View
struct TagsTextField: View {
    @Binding var tags: [String]
    @Binding var currentTextInput: String
    var onRemoveTag: (String) -> Void

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
                tags: $tags,
                placeholder: "\(String(localized: "Tags"))...",
                onCommitTag: { text in
                    let trimmed = text.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        tags.append(trimmed)
                        currentTextInput = ""
                    }
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

// MARK: - NSTextField wrapper that intercepts delete/backspace
fileprivate struct BackspaceTextField: NSViewRepresentable {
    @Binding var text: String
    @Binding var tags: [String]
    var placeholder: String
    var onCommitTag: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> _BackspaceNSTextField {
        let tf = _BackspaceNSTextField()
        tf.delegate = context.coordinator
        tf.placeholderString = placeholder
        tf.isBezeled = false
        tf.drawsBackground = false
        tf.focusRingType = .none
        tf.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        tf.cell?.wraps = false
        return tf
    }

    func updateNSView(_ uiView: _BackspaceNSTextField, context: Context) {
        if uiView.stringValue != text { uiView.stringValue = text }
        // keep caret at end if focused
        if let editor = uiView.currentEditor() as? NSTextView {
            let end = editor.string.count
            editor.selectedRange = NSRange(location: end, length: 0)
        }
    }

    class Coordinator: NSObject, NSTextFieldDelegate, NSControlTextEditingDelegate {
        var parent: BackspaceTextField
        init(_ parent: BackspaceTextField) { self.parent = parent }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            let current = textField.stringValue
            if current.hasSuffix(",") {
                let trimmed = String(current.dropLast()).trimmingCharacters(in: .whitespaces)
                parent.text = ""
                textField.stringValue = ""
                if !trimmed.isEmpty { parent.onCommitTag(trimmed) }
                return
            }
            parent.text = current
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                let trimmed = textView.string.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    parent.onCommitTag(trimmed)
                    textView.string = ""
                    parent.text = ""
                }
                return true
            }

            // Handle backspace/delete when editing via the field editor (NSTextView)
            if commandSelector == #selector(NSResponder.deleteBackward(_:)) || commandSelector == #selector(NSResponder.deleteForward(_:)) {
                if textView.string.isEmpty {
                    // Remove last tag and set it into the text field immediately
                    guard !parent.tags.isEmpty else { return false }
                    let last = parent.tags.removeLast()
                    parent.text = last
                    textView.string = last
                    return true
                }
            }

            return false
        }
    }
}

// MARK: - Custom NSTextField subclass to catch delete/backspace
fileprivate final class _BackspaceNSTextField: NSTextField {
    var onDeleteBackwardWhenEmpty: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        // keyCode 51 is the Delete (backspace) key on mac keyboards
        if event.keyCode == 51 {
            if stringValue.isEmpty {
                onDeleteBackwardWhenEmpty?()
                return
            }
        }
        super.keyDown(with: event)
    }

    // Helper to access current field editor safely
    override func currentEditor() -> NSText? {
        return self.window?.fieldEditor(false, for: self)
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
                tags = tags.filter { $0 != removedTag }
            }
            .onChange(of: currentTextInput, initial: false) { _, newValue in
                suggestedTags = newValue.isEmpty ? [] : availableTags.filter {
                    $0.lowercased().contains(newValue.lowercased())
                }
            }
        }
        if !suggestedTags.isEmpty {
            Section("Suggestions") {
                ForEach(suggestedTags, id: \.self) { tag in
                    Text(tag)
                        .onTapGesture {
                            tags.append(tag)
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
