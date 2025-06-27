//
//  DeadlineInputView.swift
//  SimpleToDoList
//

import SwiftUI

/// 一个用于设置截止日期的弹出视图。
struct DeadlineInputView: View {
    @Binding var selectedDeadline: Date?
    
    // 使用 Environment 替代闭包来关闭视图，更符合 SwiftUI 范式
    @Environment(\.dismiss) private var dismiss

    @State private var mmddInput: String = ""
    @State private var parsingError: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("设置截止日期 (MMDD)")
                .font(.headline)

            TextField("MMDD", text: $mmddInput)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .multilineTextAlignment(.center)
                .onChange(of: mmddInput) {
                    // 实时过滤和验证输入
                    let filtered = mmddInput.filter(\.isNumber)
                    mmddInput = String(filtered.prefix(4))
                    parsingError = nil
                }
            
            if let error = parsingError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .transition(.opacity)
            }

            HStack {
                Button("清除", role: .destructive, action: clearDeadline)
                Spacer()
                Button("完成", action: parseAndSetDeadline)
                    .disabled(mmddInput.count != 4)
            }
        }
        .padding()
        .frame(minWidth: 280)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onAppear(perform: setupInitialValue)
        .animation(.default, value: parsingError)
    }

    private func setupInitialValue() {
        if let deadline = selectedDeadline {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMdd"
            mmddInput = formatter.string(from: deadline)
        }
    }
    
    private func clearDeadline() {
        selectedDeadline = nil
        dismiss()
    }
    
    private func parseAndSetDeadline() {
        guard mmddInput.count == 4 else {
            parsingError = "请输入 4 位数字"
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd"
        let calendar = Calendar.current
        
        guard let dateThisYear = formatter.date(from: mmddInput) else {
            parsingError = "无效日期 (MMDD)"
            return
        }
        
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        
        var components = calendar.dateComponents([.month, .day], from: dateThisYear)
        components.year = currentYear
        // 将截止时间设为当天的结束
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        guard var targetDate = calendar.date(from: components) else {
             parsingError = "无法创建日期"
             return
         }
        
        // 如果计算出的日期在今天之前，则自动设为明年
        if targetDate < now && !calendar.isDateInToday(targetDate) {
            components.year = currentYear + 1
            targetDate = calendar.date(from: components) ?? targetDate
        }

        selectedDeadline = targetDate
        dismiss()
    }
}

