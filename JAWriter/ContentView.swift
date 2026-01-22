//
//  ContentView.swift
//  JAWriter
//
//  Created by Jake on 19/1/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var text: String = ""
    @State private var isFocusMode: Bool = false
    @State private var visibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        let writerBackground = Color(NSColor.textBackgroundColor)
        
        NavigationSplitView(columnVisibility: $visibility) {
            SidebarView().toolbar(removing: .sidebarToggle)
        } detail: {
            ZStack(alignment: .bottomTrailing) {
                writerBackground.ignoresSafeArea()
                
                WriterEditor(text: $text, isFocusMode: $isFocusMode)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)

                WordCountBar(count: text.wordCount)
                    .opacity(isFocusMode ? 0.0 : 1.0)
            }
        }.onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                self.isFocusMode = false
            }
        }.onContinuousHover { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                self.isFocusMode = false
            }
        }.onChange(of: isFocusMode) {
            withAnimation(.spring) {
                if isFocusMode {
                    visibility = NavigationSplitViewVisibility.detailOnly
                } else {
                    visibility = NavigationSplitViewVisibility.all
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
