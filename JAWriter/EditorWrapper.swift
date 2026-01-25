//
//  EditorWrapper.swift
//  JAWriter
//
//  Created by Jake on 22/1/26.
//  Intended to keep track of string state

import SwiftUI
import GoogleAPIClientForREST_Docs

struct EditorWrapper: View {
    @State private var text: String = ""
    @Binding var isFocusMode: Bool
    @Environment(GoogleManager.self) var googleManager

    var body: some View {
        let writerBackground = Color(NSColor.textBackgroundColor)
        ZStack(alignment: .bottomTrailing) {
            writerBackground.ignoresSafeArea()
            WriterEditor(isFocusMode: $isFocusMode, text: $text)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
            WordCountBar(count: text.wordCount)
                .opacity(isFocusMode ? 0.0 : 1.0)
        }
        .onChange(of: googleManager.selectedTab) {
            setText()
        }
    }
    
    func setText() {
        guard let tab = googleManager.selectedTab,
            let body = tab.documentTab?.body,
            let content = body.content else {
            self.text = ""
            return
        }
        
        let textContent = content.compactMap { element in
            element.paragraph?.elements?.compactMap { pElement in
                pElement.textRun?.content
            }
        }.flatMap { $0 }
        
        self.text = textContent.joined()
    }
}
