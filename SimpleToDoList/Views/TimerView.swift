// 文件: Views/TimerView.swift
import SwiftUI

struct TimerView: View {
    // MARK: - Properties
    
    // 计时器状态
    @State private var timeInput: String = "25" // 用户输入的分钟数
    @State private var timeRemaining: TimeInterval = 25 * 60 // 以秒为单位
    @State private var timer: Timer? = nil
    @State private var isRunning = false

    // 从父视图接收的绑定和参数
    @Binding var gradientStartColor: Color
    @Binding var gradientEndColor: Color
    let adaptiveTextColor: Color

    // MARK: - Body
    
    var body: some View {
        VStack {
            // 时间显示
            Text(timeString(from: timeRemaining))
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundColor(adaptiveTextColor)
                .padding(.vertical, 10)

            // 控制按钮
            HStack(spacing: 30) {
                // 播放/暂停
                Button(action: toggleTimer) {
                    Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .resizable().aspectRatio(contentMode: .fit).frame(width: 40, height: 40)
                }
                
                // 重置
                Button(action: resetTimer) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .resizable().aspectRatio(contentMode: .fit).frame(width: 40, height: 40)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(adaptiveTextColor) // 将自适应颜色应用到按钮

            // 时间设置与颜色选择
            HStack {
                // 时间输入框
                TextField("分钟", text: $timeInput)
                    .frame(width: 50)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .onChange(of: timeInput) {
                        // 过滤输入，只保留数字
                        let filtered = timeInput.filter { $0.isNumber }
                        self.timeInput = filtered
                        // 如果计时器未运行，则立即更新显示
                        if !isRunning {
                           resetTimer()
                        }
                    }
                Text("分钟")
                    .foregroundColor(adaptiveTextColor)
                
                Spacer()
                
                // 颜色选择器
                ColorPicker("", selection: $gradientStartColor, supportsOpacity: false)
                ColorPicker("", selection: $gradientEndColor, supportsOpacity: false)
            }
            .padding(.top, 10)
        }
        .glassCardStyle() // 应用统一的磨砂玻璃效果
    }
    
    // MARK: - Timer Logic
    
    /// 切换计时器状态（播放/暂停）
    private func toggleTimer() {
        if isRunning {
            // 暂停
            timer?.invalidate()
            isRunning = false
        } else {
            // 开始或恢复
            guard let durationMinutes = Double(timeInput), durationMinutes > 0 else { return }
            // 如果时间已到，从设定的时间重新开始
            if timeRemaining <= 0 {
                timeRemaining = durationMinutes * 60
            }
            
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    // 时间到
                    self.timer?.invalidate()
                    self.isRunning = false
                    // 在此可以添加提醒，如播放声音
                }
            }
        }
    }
    
    /// 重置计时器
    private func resetTimer() {
        timer?.invalidate()
        isRunning = false
        let durationMinutes = Double(timeInput) ?? 25.0 // 如果输入无效，则默认为25分钟
        timeRemaining = durationMinutes * 60
    }
    
    // MARK: - Formatting
    
    /// 将 TimeInterval (秒) 格式化为 MM:SS 字符串
    private func timeString(from timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
