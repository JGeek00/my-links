import SwiftUI

struct ListRowWithIconEntry: View {
    var systemIcon: String?
    var assetIcon: String?
    var iconColor: Color
    var textColor: Color
    var label: String.LocalizationValue
    
    init(systemIcon: String, iconColor: Color, textColor: Color = .foreground, label: String.LocalizationValue) {
        self.systemIcon = systemIcon
        self.assetIcon = nil
        self.textColor = textColor
        self.iconColor = iconColor
        self.label = label
    }
    
    init(assetIcon: String, iconColor: Color, textColor: Color = .foreground, label: String.LocalizationValue) {
        self.systemIcon = nil
        self.assetIcon = assetIcon
        self.iconColor = iconColor
        self.textColor = textColor
        self.label = label
    }
    
    var body: some View {
        HStack {
            if systemIcon != nil {
                Image(systemName: systemIcon!)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white)
                    .frame(width: 22, height: 22)
                    .background(iconColor)
                    .cornerRadius(6)
            }
            if assetIcon != nil {
                Group {
                    Image(assetIcon!)
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                .foregroundStyle(Color.black)
                .frame(width: 22, height: 22)
                .background(iconColor)
                .cornerRadius(6)
            }
            Text(String(localized: label))
                .padding(.leading, 8)
        }
        .foregroundStyle(textColor)
        .contentShape(Rectangle())
    }
}
