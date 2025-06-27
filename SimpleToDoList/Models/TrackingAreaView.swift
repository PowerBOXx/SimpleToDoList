// file: Utils/TrackingAreaView.swift

import SwiftUI
import AppKit

/// 一个辅助视图，用于捕获鼠标在特定区域内的移动事件。
struct TrackingAreaView: NSViewRepresentable {
    // 回调闭包，当鼠标移动时调用，传递鼠标位置
    let onMove: (CGPoint) -> Void
    // 回调闭包，当鼠标进入或离开时调用
    let onHover: (Bool) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        // 在 `updateNSView` 中统一处理 TrackingArea 的添加
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // 当视图尺寸变化时，移除旧的追踪区域并添加新的
        if let trackingArea = context.coordinator.trackingArea {
            nsView.removeTrackingArea(trackingArea)
        }
        
        let newTrackingArea = NSTrackingArea(
            rect: nsView.bounds,
            options: [
                .mouseMoved,
                .activeInKeyWindow, // 使用 .activeInKeyWindow 更为常见
                .inVisibleRect,
                .mouseEnteredAndExited
            ],
            owner: context.coordinator,
            userInfo: nil
        )
        
        nsView.addTrackingArea(newTrackingArea)
        context.coordinator.trackingArea = newTrackingArea
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onMove: onMove, onHover: onHover)
    }

    class Coordinator: NSObject {
        var onMove: (CGPoint) -> Void
        var onHover: (Bool) -> Void
        var trackingArea: NSTrackingArea?

        init(onMove: @escaping (CGPoint) -> Void, onHover: @escaping (Bool) -> Void) {
            self.onMove = onMove
            self.onHover = onHover
        }

        // 【修复】移除所有 `override` 关键字
        
        @objc func mouseMoved(with event: NSEvent) {
            // 注意：这里需要获取相对于视图的坐标，而不是窗口坐标，
            // 但由于我们在 Modifier 中做了转换，这里传递窗口坐标也是可以的。
            let point = event.locationInWindow
            onMove(point)
        }
        
        @objc func mouseEntered(with event: NSEvent) {
            onHover(true)
        }

        @objc func mouseExited(with event: NSEvent) {
            onHover(false)
        }
    }
}
