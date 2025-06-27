// file: Views/TodoListView.swift

import SwiftUI

struct TodoListView: View {
    // ... Properties 保持不变 ...
    @Binding var todoItems: [TodoItem]
    let adaptiveTextColor: Color
    @Binding var isAnimating: Bool
    let onAdd: (String, Date?) -> Void
    let onToggle: (TodoItem) -> Void
    let onClear: () -> Void
    @State private var newTodoText: String = ""
    @State private var showingDeadlinePicker = false
    @State private var selectedDeadline: Date? = nil

    private var hasCompletedTasks: Bool {
        todoItems.contains { item in item.isCompleted }
    }

    var body: some View {
        // ... body 保持不变 ...
        VStack(spacing: 15) {
            inputAreaAndClearButton
                .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach($todoItems) { $item in
                        TodoItemView(item: $item, textColor: adaptiveTextColor)
                            .glassCardStyle()
                            .onTapGesture {
                                if !isAnimating { onToggle(item) }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: todoItems)
            .mask(listFadeMask)
            .disabled(isAnimating)
        }
    }
    
    // MARK: - Subviews & Functions
    private var inputAreaAndClearButton: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                // `onCommit` 会在用户按下 Enter 键时触发 addTodo
                TextField("输入新任务...", text: $newTodoText, onCommit: addTodo)
                    .textFieldStyle(.plain)
                    .foregroundStyle(adaptiveTextColor)
                
                Divider().frame(height: 20)
                
                Button { showingDeadlinePicker = true } label: {
                    Image(systemName: selectedDeadline == nil ? "calendar.badge.plus" : "calendar.badge.clock")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(selectedDeadline == nil ? adaptiveTextColor.opacity(0.8) : .blue)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingDeadlinePicker, arrowEdge: .bottom) {
                    DeadlineInputView(selectedDeadline: $selectedDeadline).padding()
                }
                
                Button(action: addTodo) {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(adaptiveTextColor.opacity(0.8))
                }
                .buttonStyle(.plain)
                .disabled(newTodoText.trimmingCharacters(in: .whitespaces).isEmpty)
                // 【修复】移除此处的键盘快捷键，避免与 onCommit 冲突
                // .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .glassCardStyle(cornerRadius: 12)
            
            HStack {
                Spacer()
                Button("清除已完成", action: onClear)
                    .buttonStyle(.link)
                    .foregroundStyle(hasCompletedTasks ? adaptiveTextColor.opacity(0.7) : adaptiveTextColor.opacity(0.3))
                    .disabled(!hasCompletedTasks)
            }
        }
    }
    
    // ... listFadeMask 和 addTodo 函数保持不变 ...
    private var listFadeMask: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.02),
                .init(color: .black, location: 0.98),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func addTodo() {
        let trimmedText = newTodoText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }
        onAdd(trimmedText, selectedDeadline)
        newTodoText = ""
        selectedDeadline = nil
    }
}
