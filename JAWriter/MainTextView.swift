//
//  MainTextView.swift
//  JAWriter
//
//  Created by Jake on 19/1/26.
//

import Foundation
import AppKit
import SwiftUI

class JAWriterMainTextView : NSTextView {
    var isFocusModeEnabled: Bool = false {
        didSet { updateFocusEffect() }
    }
    
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        updateFocusEffect()
    }
    
    override func setSelectedRange(_ charRange: NSRange, affinity: NSSelectionAffinity, stillSelecting stillSelectingFlag: Bool) {
        super.setSelectedRange(charRange, affinity: affinity, stillSelecting: stillSelectingFlag)
        if !stillSelectingFlag {
            updateFocusEffect()
        }
    }
    

    func updateFocusEffect() {
        guard let layoutManager = self.layoutManager,
                  let storage = self.textStorage else { return }
            
            let fullRange = NSRange(location: 0, length: storage.length)
            
            // 1. Force clear everything
            layoutManager.removeTemporaryAttribute(.foregroundColor, forCharacterRange: fullRange)
            
            // 2. Explicitly grab the current dynamic colors
            let activeColor = NSColor.labelColor
            let dimmedColor = NSColor.secondaryLabelColor.withAlphaComponent(0.3)
            
            if isFocusModeEnabled {
                // Apply dimming to all
                layoutManager.addTemporaryAttributes([.foregroundColor: dimmedColor], forCharacterRange: fullRange)
                
                // Remove dimming from the active paragraph
                let currentRange = self.selectedRange()
                let paragraphRange = (storage.string as NSString).paragraphRange(for: currentRange)
                
                // This forces the active paragraph back to the dynamic 'labelColor'
                layoutManager.removeTemporaryAttribute(.foregroundColor, forCharacterRange: paragraphRange)
                layoutManager.addTemporaryAttributes([.foregroundColor: activeColor], forCharacterRange: paragraphRange)
            } else {
                // Reset the entire doc to the dynamic labelColor
                layoutManager.addTemporaryAttributes([.foregroundColor: activeColor], forCharacterRange: fullRange)
            }
    }
    
    // This intercepts the Cmd+V action
    override func paste(_ sender: Any?) {
        // 1. Pull the string only (stripping attributes) from the clipboard
        let pb = NSPasteboard.general
        if let items = pb.readObjects(forClasses: [NSString.self], options: nil),
           let string = items.first as? String {
            
            // 2. Insert it at the current cursor position
            self.insertText(string, replacementRange: self.selectedRange())
            
            // 3. Re-apply your theme font to ensure nothing changed
            self.font = NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        }
    }
    
    // Re-trigger focus mode after a paste
    override func insertText(_ insertString: Any, replacementRange: NSRange) {
        super.insertText(insertString, replacementRange: replacementRange)
        updateFocusEffect()
    }
}

struct WriterEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var isFocusMode: Bool

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        
        let textView = JAWriterMainTextView(frame: .zero)
        textView.isFocusModeEnabled = isFocusMode
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.allowsUndo = true
        textView.drawsBackground = false
        textView.isRichText = false
        textView.importsGraphics = false
        
        // Font setup (iA Writer uses specific measure/width)
        textView.font = NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        textView.typingAttributes = [
            .font: NSFont.monospacedSystemFont(ofSize: 18, weight: .regular),
            .foregroundColor: NSColor.labelColor
        ]
        textView.textContainerInset = NSSize(width: 0, height: 80)
        
        scrollView.documentView = textView
        textView.delegate = context.coordinator
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? JAWriterMainTextView else { return }
        if textView.string != text {
            textView.string = text
        }
        textView.isFocusModeEnabled = isFocusMode
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: WriterEditor
        init(_ parent: WriterEditor) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.parent.text = textView.string
            withAnimation(.easeInOut(duration: 0.4)) {
                self.parent.isFocusMode = true
            }
        }
    }
}
