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

    var body: some View {
        let writerBackground = Color(NSColor.textBackgroundColor)
        
        NavigationSplitView {
            
        } detail: {
            ZStack(alignment: .bottomTrailing) {
                writerBackground.ignoresSafeArea()
                WriterEditor(text: $text, isFocusMode: isFocusMode)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                if (!isFocusMode) {
                    WordCountBar(count: text.wordCount).transition(.opacity)
                }
            }.animation(.easeInOut, value: isFocusMode)
        }
    }
}

#Preview {
    ContentView()
}
