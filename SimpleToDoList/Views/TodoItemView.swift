// file: Views/TodoItemView.swift

import SwiftUI

/// 显示单个待办事项的视图。
struct TodoItemView: View {
    @Binding var item: TodoItem
    let textColor: Color

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(item.isCompleted ? .green : textColor.opacity(0.6))
                .symbolEffect(.bounce, value: item.isCompleted)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.text)
                    .font(.body)
                    .strikethrough(item.isCompleted, color: textColor.opacity(0.8))
                    .foregroundStyle(item.isCompleted ? textColor.opacity(0.5) : textColor)
                
                if let deadline = item.deadline {
                    deadlineText(for: deadline)
                }
            }
            
            Spacer()
        }
        // 【调整】这里不再需要单独的 padding，因为 glassCardStyle 会提供
        .contentShape(Rectangle())
    }
    
    private func deadlineText(for deadline: Date) -> some View {
        // ... 此部分逻辑不变 ...
        let isOverdue = !item.isCompleted && deadline < .now
        let isInToday = Calendar.current.isDateInToday(deadline)
        
        let deadlineString: String
        let color: Color
        
        if isOverdue {
            deadlineString = "已逾期: \(deadline.formatted(.dateTime.month().day()))"
            color = .red
        } else if isInToday {
            deadlineString = "今天截止"
            color = .orange
        } else {
            deadlineString = "截止: \(deadline.formatted(.dateTime.month().day()))"
            color = item.isCompleted ? textColor.opacity(0.4) : .secondary
        }
        
        return Text(deadlineString)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(color)
    }
}
