// 文件: Views/TodoListView.swift
import SwiftUI

struct TodoListView: View {
    // MARK: - Properties
    
    // 从父视图接收的数据和操作
    @Binding var todoItems: [TodoItem]
    let adaptiveTextColor: Color
    
    // 从父视图接收的操作闭包
    let onAdd: (String, Date?) -> Void
    let onToggle: (TodoItem) -> Void
    let onClear: () -> Void

    // 视图内部状态
    @State private var newTodoText: String = ""
    @State private var showingDeadlinePicker = false
    @State private var selectedDeadline: Date? = nil

    // 计算属性，判断是否有已完成任务
    private var hasCompletedTasks: Bool {
        todoItems.contains { $0.isCompleted }
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 15) {
            // --- 输入区域 ---
            inputArea
            
            // --- 任务列表 ---
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach($todoItems) { $item in
                        TodoItemView(item: $item, textColor: adaptiveTextColor)
                            .onTapGesture {
                                onToggle(item) // 调用父视图的 toggle 方法
                            }
                            .padding(.vertical, 4)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
            }
            .scrollContentBackground(.hidden) // 隐藏滚动视图背景，使磨砂效果生效
            .scrollIndicators(.hidden)         // 隐藏滚动条
            .animation(.default, value: todoItems) // 对列表变化应用默认动画
        }
    }
    
    // MARK: - Subviews
    
    /// 输入区域的私有视图
    private var inputArea: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                // 新任务输入框
                TextField("输入新任务...", text: $newTodoText)
                    .textFieldStyle(.plain)
                    .foregroundColor(adaptiveTextColor)
                    .padding(8)
                
                Divider().frame(height: 20)
                
                // 截止日期按钮
                Button {
                    showingDeadlinePicker = true
                } label: {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(adaptiveTextColor.opacity(0.8))
                }
                .buttonStyle(.borderless)
                .popover(isPresented: $showingDeadlinePicker, arrowEdge: .bottom) {
                    DeadlineInputView(selectedDeadline: $selectedDeadline) { deadline in
                        self.selectedDeadline = deadline
                    }
                }

                // 添加按钮
                Button {
                    // 调用父视图的 onAdd 方法
                    onAdd(newTodoText, selectedDeadline)
                    // 操作完成后，清空本地输入状态
                    newTodoText = ""
                    selectedDeadline = nil
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(adaptiveTextColor.opacity(0.8))
                }
                .buttonStyle(.borderless)
                .disabled(newTodoText.isEmpty)
                .keyboardShortcut(.return, modifiers: []) // 支持回车添加
            }
            .glassCardStyle(cornerRadius: 10) // 应用磨砂玻璃效果

            // 清除已完成按钮
            HStack {
                Spacer()
                Button("清除已完成", action: onClear) // 调用父视图的 onClear 方法
                    .buttonStyle(.link)
                    .foregroundColor(adaptiveTextColor.opacity(0.7))
                    .disabled(!hasCompletedTasks) // 当没有已完成任务时禁用
            }
        }
    }
}
