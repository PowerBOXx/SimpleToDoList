// file: Views/Shared/ViewModifiers.swift

import SwiftUI

struct GlassMorphicCardModifier: ViewModifier {
    var cornerRadius: CGFloat

    private var borderGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                .white.opacity(0.4), .white.opacity(0.1), .white.opacity(0.05),
                .white.opacity(0.2), .white.opacity(0.4)
            ]),
            center: .center
        )
    }

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 14)
            .padding(.horizontal)
            .background(.ultraThinMaterial.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderGradient, lineWidth: 1.5)
            }
            // 【移除】不再调用 parallaxHighlight
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
    }
}

// MARK: - FrostedText Modifier (保持不变)
struct FrostedTextModifier: ViewModifier {
    var textColor: Color

    func body(content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(textColor)
            content
                .foregroundStyle(.ultraThinMaterial)
                .blendMode(.sourceAtop)
        }
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
}

// MARK: - View Extensions
extension View {
    func glassCardStyle(cornerRadius: CGFloat = 14.0) -> some View {
        modifier(GlassMorphicCardModifier(cornerRadius: cornerRadius))
    }
    
    func frostedTextStyle(with textColor: Color) -> some View {
        modifier(FrostedTextModifier(textColor: textColor))
    }
}
