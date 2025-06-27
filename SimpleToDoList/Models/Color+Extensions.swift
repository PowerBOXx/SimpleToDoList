//
//  Color+Extensions.swift
//  SimpleToDoList
//
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Codable Support for Color
// 使得 SwiftUI.Color 可以被 AppStorage 持久化

private struct CodableColor: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

extension Color {
    /// 将 SwiftUI.Color 转换为可被序列化的中间结构体。
    /// - Returns: 一个包含 RGBA 值的 `CodableColor` 实例，若转换失败则返回 nil。
    fileprivate func toCodable() -> CodableColor? {
        // 在 macOS 上使用 NSColor 获取 sRGB 色彩空间的颜色分量。
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return CodableColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 从 `CodableColor` 结构体初始化 SwiftUI.Color。
    /// - Parameter codableColor: 包含 RGBA 值的 `CodableColor` 实例。
    fileprivate init(codableColor: CodableColor) {
        self.init(
            .sRGB,
            red: codableColor.red,
            green: codableColor.green,
            blue: codableColor.blue,
            opacity: codableColor.alpha
        )
    }
}

// MARK: - Data Persistence for Color
// 使用 @AppStorage 包装器，简化颜色的存储和读取。

extension Color: @retroactive RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let codableColor = try? JSONDecoder().decode(CodableColor.self, from: data) else {
            return nil
        }
        self.init(codableColor: codableColor)
    }

    public var rawValue: String {
        guard let codable = self.toCodable(),
              let data = try? JSONEncoder().encode(codable),
              let jsonString = String(data: data, encoding: .utf8) else {
            return ""
        }
        return jsonString
    }
}


// MARK: - Luminance Calculation

extension Color {
    /// 计算颜色的感知亮度，返回值在 0 (纯黑) 到 1 (纯白) 之间。
    var luminance: CGFloat {
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else { return 0 }
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        nsColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        
        // 使用 Rec. 709 Luma 标准公式，更现代且准确。
        // Y = 0.2126R + 0.7152G + 0.0722B
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    /// 判断颜色是否偏暗。
    /// - Parameter threshold: 亮度阈值，低于此值则认为是暗色。0.5 是一个常用的平衡点。
    /// - Returns: 如果颜色亮度低于阈值，则返回 `true`。
    func isDark(threshold: CGFloat = 0.5) -> Bool {
        return self.luminance < threshold
    }
}

