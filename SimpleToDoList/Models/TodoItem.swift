//
//  TodoItem.swift
//  SimpleToDoList
//
import Foundation

// MARK: - TodoItem Model
/// 代表一个待办事项。
/// 符合 Identifiable, Codable, 和 Equatable 协议，便于在 SwiftUI 列表、持久化和比较中使用。
struct TodoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: String
    var isCompleted: Bool = false
    var deadline: Date?
    let createdAt: Date

    /// 便利初始化器，自动设置 `createdAt` 为当前时间。
    init(
        id: UUID = UUID(),
        text: String,
        isCompleted: Bool = false,
        deadline: Date? = nil,
        createdAt: Date = .now // 使用 .now 替代 Date()
    ) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
        self.deadline = deadline
        self.createdAt = createdAt
    }
}

