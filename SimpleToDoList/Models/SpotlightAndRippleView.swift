// file: Views/Shared/SpotlightAndRippleView.swift

import SwiftUI
import Combine

/// 一个全局覆盖视图，用于创建顶层的、不阻挡交互的聚光灯和点击涟漪效果。
struct SpotlightAndRippleView: View {
    // MARK: - State Properties
    @State private var mouseLocation: CGPoint = .zero
    @State private var ripples: [Ripple] = []
    @State private var isWindowActive: Bool = false
    
    // 用于接收全局点击事件的发布者
    let clickPublisher: PassthroughSubject<CGPoint, Never>

    // 聚光灯的渐变
    private var spotlightGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [.white.opacity(0.55), .white.opacity(0.0)]),
            center: .center, startRadius: 2, endRadius: 36
        )
    }

    var body: some View {
        ZStack {
            // 聚光灯效果
            spotlightGradient
                .blur(radius: 10)
                .position(mouseLocation)
                .opacity(isWindowActive ? 1 : 0)
            
            // 涟漪效果
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(Color.white, lineWidth: ripple.isEnding ? 0 : 2)
                    .frame(width: ripple.scale, height: ripple.scale)
                    .position(ripple.location)
                    .opacity(ripple.opacity)
            }
        }
        .allowsHitTesting(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onContinuousHover(coordinateSpace: .global) { phase in
            if case .active(let location) = phase {
                self.mouseLocation = location
            }
        }
        .onReceive(clickPublisher) { location in
            createRipple(at: location)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            isWindowActive = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            isWindowActive = false
        }
    }

    private func createRipple(at location: CGPoint) {
        let newRipple = Ripple(location: location)
        ripples.append(newRipple)
        
        // 使用 withAnimation 来驱动涟漪的生长和消失
        withAnimation(.easeOut(duration: 0.6)) {
            // 【修复】使用明确的参数名 `ripple` 替代 `\$0`，防止 KeyPath 误报。
            guard let index = ripples.firstIndex(where: { ripple in
                ripple.id == newRipple.id
            }) else { return }
            
            ripples[index].scale = 100
            ripples[index].opacity = 0
            ripples[index].isEnding = true
        }
        
        // 动画结束后从数组中移除，以保持性能
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // 【修复】使用明确的参数名 `ripple` 替代 `\$0`，防止 KeyPath 误报。
            ripples.removeAll { ripple in
                ripple.id == newRipple.id
            }
        }
    }
}

/// 代表一个涟漪的数据结构
struct Ripple: Identifiable {
    let id = UUID()
    let location: CGPoint
    var scale: CGFloat = 10
    var opacity: Double = 0.5
    var isEnding: Bool = false
}
