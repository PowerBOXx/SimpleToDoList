// 文件: Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    
    // 使用 @AppStorage 持久化待办事项和颜色
    @AppStorage("todoItems") private var todoItemsData: Data = Data()
    @AppStorage("gradientStartColor") private var gradientStartColorData: Data = Data()
    @AppStorage("gradientEndColor") private var gradientEndColorData: Data = Data()
    
    // 状态变量
    @State private var todoItems: [TodoItem] = []
    @State private var gradientStartColor: Color = .blue
    @State private var gradientEndColor: Color = .purple

    // 基于背景亮度计算自适应文本颜色
    private var adaptiveTextColor: Color {
        let averageLuminance = (gradientStartColor.luminance + gradientEndColor.luminance) / 2
        // 如果平均亮度低于阈值 (偏暗)，则使用白色文本，否则使用黑色文本
        return averageLuminance < 0.5 ? .white : .black
    }

    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 1. 全局渐变背景
            LinearGradient(
                colors: [gradientStartColor, gradientEndColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut, value: [gradientStartColor, gradientEndColor])

            // 2. 主 UI 布局
            VStack(spacing: 0) {
                // 待办事项列表视图，将数据和操作传递进去
                TodoListView(
                    todoItems: $todoItems,
                    adaptiveTextColor: adaptiveTextColor,
                    onAdd: addTodo,
                    onToggle: toggleCompletion,
                    onClear: clearCompleted
                )
                .padding()

                Divider().padding(.horizontal)

                // 计时器视图，传递颜色绑定和自适应文本颜色
                TimerView(
                    gradientStartColor: $gradientStartColor,
                    gradientEndColor: $gradientEndColor,
                    adaptiveTextColor: adaptiveTextColor
                )
                .padding()
            }
        }
        .onAppear(perform: loadData)
        .onChange(of: todoItems) { saveItems() }
        .onChange(of: gradientStartColor) { saveColors() }
        .onChange(of: gradientEndColor) { saveColors() }
    }
    
    // MARK: - Data Logic (所有逻辑都集中在这里)
    
    /// 添加一个新的待办事项
    func addTodo(text: String, deadline: Date?) {
        let newItem = TodoItem(text: text, deadline: deadline)
        withAnimation {
            todoItems.append(newItem)
            sortItems()
        }
    }
    
    /// 清除所有已完成的任务
    func clearCompleted() {
        withAnimation {
            todoItems.removeAll { $0.isCompleted }
        }
    }
    
    /// 切换指定任务的完成状态
    func toggleCompletion(for item: TodoItem) {
        guard let index = todoItems.firstIndex(where: { $0.id == item.id }) else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            todoItems[index].isCompleted.toggle()
            sortItems()
        }
    }

    /// 对待办事项列表进行排序
    private func sortItems() {
        todoItems.sort {
            // 主要排序：未完成的在前 (false < true)
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted && $1.isCompleted
            }
            // 次要排序：按创建时间排序（越早创建越靠前）
            return $0.createdAt < $1.createdAt
        }
    }

    // MARK: - Persistence
    
    /// 从 AppStorage 加载所有持久化的数据
    private func loadData() {
        // 1. 加载待办事项列表
        if !todoItemsData.isEmpty, let decodedItems = try? JSONDecoder().decode([TodoItem].self, from: todoItemsData) {
            todoItems = decodedItems
            sortItems() // 加载后立即排序以保持一致性
        }
        
        // 2. 加载颜色数据
        let decoder = JSONDecoder()
        if !gradientStartColorData.isEmpty,
           let codableStartColor = try? decoder.decode(CodableColor.self, from: gradientStartColorData) {
            self.gradientStartColor = Color(codableColor: codableStartColor)
        }
        
        if !gradientEndColorData.isEmpty,
           let codableEndColor = try? decoder.decode(CodableColor.self, from: gradientEndColorData) {
            self.gradientEndColor = Color(codableColor: codableEndColor)
        }
    }

    /// 保存待办事项列表到 AppStorage
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(todoItems) {
            todoItemsData = encoded
        }
    }
    
    /// 保存渐变颜色到 AppStorage
    private func saveColors() {
        let encoder = JSONEncoder()
        
        // 保存起始颜色
        if let codableStart = gradientStartColor.toCodable(),
           let encodedStart = try? encoder.encode(codableStart) {
            gradientStartColorData = encodedStart
        }
        
        // 保存结束颜色
        if let codableEnd = gradientEndColor.toCodable(),
           let encodedEnd = try? encoder.encode(codableEnd) {
            gradientEndColorData = encodedEnd
        }
    }
}


