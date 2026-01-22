//
//  ContentView.swift
//  JAWriter
//
//  Created by Jake on 19/1/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isFocusMode: Bool = false
    @State private var visibility = NavigationSplitViewVisibility.all
    @State private var selectedDocumentId: String? = nil
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            SidebarView(selectedDocumentId: $selectedDocumentId).toolbar(removing: .sidebarToggle)
        } detail: {
            EditorWrapper(isFocusMode: $isFocusMode, selectedDocumentId: $selectedDocumentId)
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
