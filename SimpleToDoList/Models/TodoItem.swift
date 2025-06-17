import Foundation

// 确保符合 Equatable 以便 onChange 和排序工作
struct TodoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: String
    var isCompleted: Bool = false
    var deadline: Date? = nil
    let createdAt: Date // 添加创建时间戳

    // 初始化器，自动设置 createdAt
    init(id: UUID = UUID(), text: String, isCompleted: Bool = false, deadline: Date? = nil, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
        self.deadline = deadline
        self.createdAt = createdAt // 设置当前时间
    }

    // Equatable 由编译器自动合成，因为所有属性都符合 Equatable
}
