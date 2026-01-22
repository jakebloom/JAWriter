//
//  EditorWrapper.swift
//  JAWriter
//
//  Created by Jake on 22/1/26.
//  Intended to keep track of string state

import SwiftUI

struct EditorWrapper: View {
    @State private var text: String = ""
    @Binding var isFocusMode: Bool
    @Binding var selectedDocumentId: String?
    @State private var authManager = GoogleAuthManager.shared

    var body: some View {
        let writerBackground = Color(NSColor.textBackgroundColor)
        ZStack(alignment: .bottomTrailing) {
            writerBackground.ignoresSafeArea()
            WriterEditor(isFocusMode: $isFocusMode, text: $text)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
            WordCountBar(count: text.wordCount)
                .opacity(isFocusMode ? 0.0 : 1.0)
        }.onChange(of: selectedDocumentId) {
            fetchDocument()
        }
    }
    
    func fetchDocument() {
        guard let selectedDocumentId = selectedDocumentId,
            let currentUser = authManager.currentUser else { return }
        GoogleDocsService(user: currentUser).downloadMarkdown(fileId: selectedDocumentId) { res in
            self.text = res ?? self.text
        }
    }
}
