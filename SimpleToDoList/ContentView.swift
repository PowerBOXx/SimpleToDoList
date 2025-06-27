// file: ContentView.swift

import SwiftUI
import Combine

struct ContentView: View {
    // MARK: - State Properties
    @AppStorage("todoItems") private var todoItemsData: Data = Data()
    @AppStorage("gradientStartColor") private var gradientStartColor: Color = .blue
    @AppStorage("gradientEndColor") private var gradientEndColor: Color = .purple
    
    @State private var todoItems: [TodoItem] = []
    @State private var isAnimating: Bool = false
    
    // 【新增】用于在全局监视器和视图之间传递点击事件的发布者
    @State private var clickPublisher = PassthroughSubject<CGPoint, Never>()
    // 【新增】全局事件监视器实例
    @State private var eventMonitor: GlobalEventMonitor?

    private var adaptiveTextColor: Color {
        let averageLuminance = (gradientStartColor.luminance + gradientEndColor.luminance) / 2
        return averageLuminance < 0.5 ? .white : .black
    }

    var body: some View {
        ZStack {
            // 底层背景
            backgroundGradient
            
            // 中层可交互内容
            VStack(spacing: 0) {
                TodoListView(
                    todoItems: $todoItems,
                    adaptiveTextColor: adaptiveTextColor,
                    isAnimating: $isAnimating,
                    onAdd: addTodo,
                    onToggle: toggleCompletion,
                    onClear: clearCompleted
                )
                .layoutPriority(1)

                Divider()
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)

                TimerView(
                    gradientStartColor: $gradientStartColor,
                    gradientEndColor: $gradientEndColor,
                    adaptiveTextColor: adaptiveTextColor
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
            
            // 【核心】顶层效果视图，它不会阻挡交互
            SpotlightAndRippleView(clickPublisher: clickPublisher)
        }
        .onAppear {
            // 当视图出现时，启动全局事件监视器
            self.eventMonitor = GlobalEventMonitor(mask: .leftMouseDown) { event in
                // 当检测到鼠标左键按下时，获取窗口中的位置并发送
                if let window = NSApplication.shared.windows.first {
                    let locationInWindow = event.locationInWindow
                    // SwiftUI 坐标系的原点在左上角，AppKit 在左下角，需要转换
                    let locationForSwiftUI = CGPoint(
                        x: locationInWindow.x,
                        y: window.frame.height - locationInWindow.y
                    )
                    self.clickPublisher.send(locationForSwiftUI)
                }
            }
            self.eventMonitor?.start()
            
            // 加载数据
            loadItems()
        }
        .onDisappear {
            // 当视图消失时，停止监视器以防内存泄漏
            self.eventMonitor?.stop()
        }
        .task(id: todoItems, saveItems)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [gradientStartColor, gradientEndColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.8), value: gradientStartColor)
        .animation(.easeInOut(duration: 0.8), value: gradientEndColor)
    }
    
    // ... Data Logic & Persistence (保持不变) ...
    private func addTodo(text: String, deadline: Date?) {
           let newItem = TodoItem(text: text, deadline: deadline)
           todoItems.append(newItem)
           sortItems()
       }
       
       private func clearCompleted() {
           todoItems.removeAll { item in item.isCompleted }
       }
       
       private func toggleCompletion(for itemToToggle: TodoItem) {
           guard let index = todoItems.firstIndex(where: { item in item.id == itemToToggle.id }) else { return }
           isAnimating = true
           todoItems[index].isCompleted.toggle()
           sortItems()
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
               self.isAnimating = false
           }
       }

       private func sortItems() {
           todoItems.sort { item1, item2 in
               if item1.isCompleted != item2.isCompleted {
                   return !item1.isCompleted && item2.isCompleted
               }
               return item1.createdAt < item2.createdAt
           }
       }
       
       private func loadItems() {
           guard !todoItemsData.isEmpty,
                 let decodedItems = try? JSONDecoder().decode([TodoItem].self, from: todoItemsData)
           else { return }
           self.todoItems = decodedItems
           sortItems()
       }
       
       @Sendable
       private func saveItems() async {
           guard let encoded = try? JSONEncoder().encode(todoItems) else { return }
           todoItemsData = encoded
       }
}

// 补全 ContentView 的子视图和函数
extension ContentView {
    private var todoListView: some View {
        TodoListView(
            todoItems: $todoItems,
            adaptiveTextColor: adaptiveTextColor,
            isAnimating: $isAnimating,
            onAdd: addTodo,
            onToggle: toggleCompletion,
            onClear: clearCompleted
        )
        .layoutPriority(1)
    }

    private var timerView: some View {
        TimerView(
            gradientStartColor: $gradientStartColor,
            gradientEndColor: $gradientEndColor,
            adaptiveTextColor: adaptiveTextColor
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
