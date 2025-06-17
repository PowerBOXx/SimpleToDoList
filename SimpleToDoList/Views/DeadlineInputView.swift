//
//  DeadlineInputView.swift
//  SimpleToDoList
//
import SwiftUI

struct DeadlineInputView: View {
    @Binding var selectedDeadline: Date?
    var onDeadlineSet: (Date?) -> Void

    @State private var mmddInput: String = ""
    @State private var parsingError: String? = nil
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("设置截止日期 (MMDD)").font(.headline).padding(.top)
            
            TextField("MMDD", text: $mmddInput)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .multilineTextAlignment(.center)
                .onChange(of: mmddInput) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    mmddInput = String(filtered.prefix(4))
                    parsingError = nil
                }
            
            if let error = parsingError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 2)
            }

            HStack {
                Button("清除", action: clearDeadline)
                Spacer()
                Button("完成", action: parseAndSetDeadline)
                    .disabled(mmddInput.count != 4)
            }
            .padding([.horizontal, .bottom])
        }
        .padding(.horizontal)
        .frame(minWidth: 250)
        .background(.ultraThinMaterial) // 直接应用 Material 背景
        .cornerRadius(15)
        .onAppear(perform: setupInitialValue)
    }

    private func setupInitialValue() {
        if let deadline = selectedDeadline {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMdd"
            mmddInput = formatter.string(from: deadline)
        } else {
            mmddInput = ""
        }
        parsingError = nil
    }
    
    private func clearDeadline() {
        selectedDeadline = nil
        onDeadlineSet(nil)
        dismiss()
    }
    
    private func parseAndSetDeadline() {
        guard mmddInput.count == 4 else {
            parsingError = "请输入 4 位数字"
            return
        }
        // ... (解析逻辑保持不变) ...
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        guard let dateCurrentYear = formatter.date(from: mmddInput) else {
            parsingError = "无效的日期格式 (MMDD)"
            return
        }
        var components = calendar.dateComponents([.month, .day], from: dateCurrentYear)
        components.year = currentYear
        components.hour = 23
        components.minute = 59
        components.second = 59
        guard var targetDate = calendar.date(from: components) else {
             parsingError = "无法创建日期"
             return
         }
        if targetDate < now && !calendar.isDateInToday(targetDate) {
             components.year = currentYear + 1
             guard let nextYearDate = calendar.date(from: components) else {
                 parsingError = "无法创建明年日期"
                 return
             }
            targetDate = nextYearDate
        }
        selectedDeadline = targetDate
        onDeadlineSet(targetDate)
        parsingError = nil
        dismiss()
    }
}

