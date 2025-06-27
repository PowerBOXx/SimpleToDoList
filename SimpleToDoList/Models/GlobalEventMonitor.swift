//
//  GlobalEventMonitor..swift
//  SimpleToDoList
//

import SwiftUI
import AppKit

/// 一个用于监听全局鼠标事件的类。
class GlobalEventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent) -> Void

    /// 初始化一个全局事件监视器。
    /// - Parameters:
    ///   - mask: 要监听的事件类型（例如，鼠标按下）。
    ///   - handler: 处理事件的回调闭包。
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    /// 开始监听事件。
    public func start() {
        // 确保不会重复启动
        guard monitor == nil else { return }
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    /// 停止监听事件。
    public func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}

