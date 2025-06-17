//
//  TodoItemView.swift
//  SimpleToDoList
//
import SwiftUI

struct TodoItemView: View {
    @Binding var item: TodoItem
    var textColor: Color // 接收自适应颜色

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(item.isCompleted ? .green : textColor.opacity(0.6)) // 应用

            VStack(alignment: .leading, spacing: 2) {
                Text(item.text)
                    .strikethrough(item.isCompleted, color: textColor) // 应用
                    .foregroundColor(item.isCompleted ? textColor.opacity(0.5) : textColor) // 应用
                
                if let deadline = item.deadline {
                    Text("截止: \(deadline, formatter: dateFormatterMMdd)")
                        .font(.caption)
                        .foregroundColor(item.isCompleted ? textColor.opacity(0.4) : .orange) // 截止日期颜色可以保持橙色，或也使用 textColor.opacity(0.7)
                }
            }
            .animation(.easeInOut, value: item.isCompleted)
            
            Spacer()
        }
        .glassCardStyle()
    }
    private let dateFormatterMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()
}
