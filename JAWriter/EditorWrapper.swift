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
    @Environment(WriterFileManager.self) var wfileManager

    var body: some View {
        let writerBackground = Color(NSColor.textBackgroundColor)
        ZStack(alignment: .bottomTrailing) {
            writerBackground.ignoresSafeArea()
            
            if wfileManager.selectedDocument != nil {
                WriterEditor(isFocusMode: $isFocusMode, text: $text)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)
                WordCountBar(count: text.wordCount)
                    .opacity(isFocusMode ? 0.0 : 1.0)
                    .environment(wfileManager)
            }
        }
        .onChange(of: wfileManager.selectedDocument) {
            setText()
        }
        .onChange(of: isFocusMode) {
            if !isFocusMode {
                wfileManager.writeFile(text)
            }
        }
    }
    
    func setText() {
        self.text = wfileManager.getText()
    }
}
