//
//  ContentView.swift
//  JAWriter
//
//  Created by Jake on 19/1/26.
//

import SwiftUI
import SwiftData
import GoogleAPIClientForREST_Docs

struct ContentView: View {
    @State private var isFocusMode: Bool = false
    @State private var visibility = NavigationSplitViewVisibility.all
    @State private var googleManager: GoogleManager = GoogleManager()
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            SidebarView()
                .environment(googleManager)
                .toolbar(removing: .sidebarToggle)
        } content: {
          TabListView()
                .environment(googleManager)
        } detail: {
            EditorWrapper(isFocusMode: $isFocusMode)
                .environment(googleManager)
        }.onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                self.isFocusMode = false
                print("unset focus mode (lost focus)")
            }
        }.onContinuousHover { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                self.isFocusMode = false
                print("unset focus mode (mouse move)")
            }
        }.onChange(of: isFocusMode) {
            withAnimation(.spring) {
                if isFocusMode {
                    visibility = NavigationSplitViewVisibility.detailOnly
                } else {
                    visibility = NavigationSplitViewVisibility.all
                }
            }
        }.onAppear() {
            googleManager.restoreSignIn()
        }
    }
}

#Preview {
    ContentView()
}
