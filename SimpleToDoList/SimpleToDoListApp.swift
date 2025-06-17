//
//  SimpleToDoListApp.swift
//  SimpleToDoList
//

import SwiftUI

@main
struct SimpleToDoListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 280, idealWidth: 320, maxWidth: .infinity, // Width constraints
                       minHeight: 400, idealHeight: 600, maxHeight: .infinity) // Height constraints
        }
        // Attempt to position the window on the left edge at launch
        // Note: SwiftUI's control over exact initial position can be limited.
        // This provides a hint to the system.
        .defaultPosition(.leading)
        // Make the window non-resizable if desired
        // .windowResizability(.contentSize)
        // Give the window a title
        .windowToolbarStyle(.unifiedCompact) // Example style
        // You might need AppDelegate for more precise window control on launch if .defaultPosition isn't enough.

         // --- Optional: Settings Scene (if you add settings later) ---
         /*
         Settings {
             // Your settings view here
             Text("App Settings")
                 .padding()
         }
         */
    }
}

// --- Optional: AppDelegate for finer window control ---
/*
 // Uncomment this and add `@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate`
 // inside your App struct if needed.

 class AppDelegate: NSObject, NSApplicationDelegate {
     func applicationDidFinishLaunching(_ notification: Notification) {
         if let window = NSApplication.shared.windows.first {
             positionWindow(window)
         } else {
             // Window might not be ready yet, try delaying slightly
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                 if let window = NSApplication.shared.windows.first {
                     self.positionWindow(window)
                 }
             }
         }
     }

     func positionWindow(_ window: NSWindow) {
         guard let screen = window.screen ?? NSScreen.main else { return }
         let screenFrame = screen.visibleFrame // Area excluding Dock and Menu Bar
         let windowSize = window.frame.size // Get current window size
         
         // Calculate new origin
         let newOrigin = CGPoint(x: screenFrame.minX, // Left edge
                                 y: screenFrame.maxY - windowSize.height) // Top edge (adjust if needed)

         // Set the window's top-left corner position
         window.setFrameOrigin(newOrigin)
         
         // Optional: Set a fixed height matching the screen height if desired
         // var newFrame = window.frame
         // newFrame.size.height = screenFrame.height
         // newFrame.origin.y = screenFrame.minY // Align bottom if changing height
         // window.setFrame(newFrame, display: true)

     }
 }
*/
