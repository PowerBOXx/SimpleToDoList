//
//  SimpleToDoListApp.swift
//  SimpleToDoList
//

import SwiftUI

@main
struct SimpleToDoListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 设置窗口的理想尺寸和限制
                .frame(
                    minWidth: 320, idealWidth: 380, maxWidth: .infinity,
                    minHeight: 500, idealHeight: 700, maxHeight: .infinity
                )
        }
        // 使用更现代、紧凑的工具栏样式
        .windowToolbarStyle(.unifiedCompact)
        // 尝试将窗口默认放置在屏幕左侧
        .defaultPosition(.leading)
        // 可选：如果希望窗口大小固定，取消注释下一行
        // .windowResizability(.contentSize)
    }
}
