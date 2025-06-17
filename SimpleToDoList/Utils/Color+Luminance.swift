//
//  Color+Luminance.swift
//  SimpleToDoList
//
//  这个文件扩展了 SwiftUI 的 Color 类型，增加了两个核心功能：
//  1. 计算颜色的感知亮度 (Luminance)，用于判断颜色是深是浅。
//  2. 实现 Codable 协议，使得 Color 类型可以被编码为 Data (例如 JSON) 和从 Data 中解码，
//     以便使用 @AppStorage 等机制进行持久化。
//

import SwiftUI
import AppKit // 在 macOS 上，使用 AppKit 的 NSColor 来访问底层的颜色分量

// MARK: - Codable Support for Color

/// 一个可编码/解码的中间结构体，用于存储颜色的 RGBA 分量。
/// 这是必需的，因为 SwiftUI.Color 本身不符合 Codable 协议。
struct CodableColor: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

extension Color {
    
    /// 将 SwiftUI 的 Color 实例转换为可被序列化的 CodableColor 结构体。
    /// - Returns: 一个包含 RGBA 值的 CodableColor 实例，如果转换失败则返回 nil。
    func toCodable() -> CodableColor? {
        // 使用 NSColor 作为桥梁来获取 sRGB 空间的颜色分量。
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else {
            return nil
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return CodableColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// 使用 CodableColor 结构体来初始化一个 SwiftUI 的 Color 实例。
    /// - Parameter codableColor: 一个包含 RGBA 值的 CodableColor 实例。
    init(codableColor: CodableColor) {
        self.init(.sRGB,
                  red: codableColor.red,
                  green: codableColor.green,
                  blue: codableColor.blue,
                  opacity: codableColor.alpha)
    }
}


// MARK: - Luminance Calculation

extension Color {
    
    /// 计算颜色的感知亮度。
    /// 返回值在 0 (纯黑) 到 1 (纯白) 之间。
    var luminance: CGFloat {
        // 同样使用 NSColor 作为桥梁来获取颜色分量。
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else { return 0 }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        // 使用标准的亮度计算公式 (W3C/Rec. 709 Luma)
        // Y = 0.2126R + 0.7152G + 0.0722B 是更现代和准确的标准，
        // 但 0.299R + 0.587G + 0.114B 同样被广泛使用且效果良好。
        return 0.299 * red + 0.587 * green + 0.114 * blue
    }
    
    /// 判断颜色是否偏暗。
    /// - Parameter threshold: 亮度阈值，低于此值则认为是暗色。0.5 是一个常用的平衡点。
    /// - Returns: 如果颜色亮度低于阈值，则为 true。
    func isDark(threshold: CGFloat = 0.5) -> Bool {
        return self.luminance < threshold
    }
}
