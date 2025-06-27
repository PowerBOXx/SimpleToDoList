// file: Views/TimerView.swift

import SwiftUI

struct TimerView: View {
    @Binding var gradientStartColor: Color
    @Binding var gradientEndColor: Color
    let adaptiveTextColor: Color

    @State private var timeInput: String = "25"
    @State private var timeRemaining: TimeInterval = 25 * 60
    @State private var timer: Timer?
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 20) {
            // 【优化】调整计时器字体大小，使其更突出
            Text(timeString(from: timeRemaining))
                .font(.system(size: 72, weight: .bold, design: .monospaced))
                .frame(maxWidth: .infinity)
                .minimumScaleFactor(0.5)
                .padding(.vertical, 10)
                .frostedTextStyle(with: adaptiveTextColor)

            HStack(spacing: 40) {
                controlButton(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill", action: toggleTimer)
                controlButton(systemName: "arrow.clockwise.circle.fill", action: resetTimer)
            }
            .foregroundStyle(adaptiveTextColor)
            .font(.system(size: 44))

            HStack(spacing: 15) {
                TextField("", text: $timeInput)
                    .font(.system(size: 16)) // 【优化】增大输入框字体
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .onChange(of: timeInput, handleTimeInputChange)
                
                Text("分钟").font(.system(size: 16)).opacity(0.8) // 【优化】增大"分钟"字体
                Spacer()
                
                // 【修复】直接使用官方 ColorPicker，不加任何可能干扰交互的修饰符
                ColorPicker("", selection: $gradientStartColor, supportsOpacity: false)
                    .labelsHidden()
                    
                ColorPicker("", selection: $gradientEndColor, supportsOpacity: false)
                    .labelsHidden()
            }
            .padding(.top, 10)
            .foregroundStyle(adaptiveTextColor)
        }
        .padding(EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)) // 【优化】统一内边距
        .glassCardStyle()
    }
    
    // MARK: - Helper Functions

    // 【修复】将所有函数实现直接放在这里，不再使用 extension
    
    private func controlButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
        }
        .buttonStyle(.plain)
    }
    
    private func handleTimeInputChange() {
        let filtered = timeInput.filter { item in item.isNumber }
        if let number = Int(filtered), number > 0 {
            timeInput = String(number)
        } else {
            timeInput = ""
        }
        
        if !isRunning {
            resetTimer()
        }
    }
    
    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
        } else {
            guard let duration = Double(timeInput), duration > 0 else { return }
            if timeRemaining <= 0 {
                timeRemaining = duration * 60
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.isRunning = false
                }
            }
        }
        isRunning.toggle()
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        let durationMinutes = Double(timeInput) ?? 25.0
        timeRemaining = max(1, durationMinutes) * 60
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(timeInterval))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
