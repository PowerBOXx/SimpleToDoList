//
//  GlassStyle.swift
//  SimpleToDoList
//

import SwiftUI

struct GlassMorphicCard: ViewModifier {
    var cornerRadius: CGFloat

    // 创建一个带有光泽效果的渐变描边
    private var borderGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                .white.opacity(0.4),
                .white.opacity(0.1),
                .white.opacity(0.4),
                .white.opacity(0.1),
                .white.opacity(0.4)
            ]),
            center: .center
        )
    }

    func body(content: Content) -> some View {
        content
            .padding()
            // 1. 使用原生的 .ultraThinMaterial，不加 .opacity() 以获得最清晰的模糊效果
            .background(Material.ultraThinMaterial.opacity(0.4))
            .cornerRadius(cornerRadius)
            // 2. 使用我们创建的渐变描边来模拟光泽
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderGradient, lineWidth: 1.5)
            )
            // 3. 稍微调整阴影使其更柔和
            .shadow(color: .black.opacity(0.2), radius: 3, x: 1, y: 2)
    }
}

extension View {
    func glassCardStyle(cornerRadius: CGFloat = 20.0) -> some View {
        // 默认圆角可以稍微大一点，更有现代感
        self.modifier(GlassMorphicCard(cornerRadius: cornerRadius))
    }
}
