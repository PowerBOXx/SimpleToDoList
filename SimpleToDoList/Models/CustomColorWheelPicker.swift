// file: Views/Shared/CustomColorWheelPicker.swift

import SwiftUI

/// 一个自定义外观的按钮，点击后触发系统的颜色选择器。
struct CustomColorWheelPicker: View {
    let label: String
    @Binding var selection: Color

    var body: some View {
        // 将自定义外观作为底层，将透明的 ColorPicker 作为可点击的覆盖层
        Rectangle()
            .fill(selection)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.white.opacity(0.6), lineWidth: 1)
            }
            .shadow(radius: 2)
            .frame(width: 30, height: 20)
            .overlay {
                // 透明的 ColorPicker 在最顶层，负责接收所有点击事件。
                ColorPicker(label, selection: $selection, supportsOpacity: false)
                    .labelsHidden()
                    .opacity(0.015) // 必须有极低的透明度才能保持可交互性
            }
    }
}
