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
    var isFocusModeEnabled: Bool = true {
        didSet { updateFocusEffect() }
    }
    
    override func setSelectedRange(_ charRange: NSRange, affinity: NSSelectionAffinity, stillSelecting stillSelectingFlag: Bool) {
        super.setSelectedRange(charRange, affinity: affinity, stillSelecting: stillSelectingFlag)
        updateFocusEffect()
    }
    
    func updateFocusEffect() {
        guard let storage = textStorage else { return }

        // 1. Reset everything to a "dimmed" state
        let fullRange = NSRange(location: 0, length: storage.length)
        let dimmedColor = NSColor.secondaryLabelColor.withAlphaComponent(0.3)
        let activeColor = NSColor.labelColor
        
        storage.beginEditing()
        
        if isFocusModeEnabled {
            // Dim all text
            storage.addAttribute(.foregroundColor, value: dimmedColor, range: fullRange)
            
            // 2. Highlight ONLY the current paragraph
            let currentRange = self.selectedRange()
            let paragraphRange = (storage.string as NSString).paragraphRange(for: currentRange)
            storage.addAttribute(.foregroundColor, value: activeColor, range: paragraphRange)
        } else {
            // Reset to normal
            storage.addAttribute(.foregroundColor, value: activeColor, range: fullRange)
        }
        
        storage.endEditing()
    }
}

struct WriterEditor: NSViewRepresentable {
    var text: String
    var isFocusMode: Bool

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        
        let textView = JAWriterMainTextView(frame: .zero)
        textView.isFocusModeEnabled = isFocusMode
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.allowsUndo = true
        
        // Font setup (iA Writer uses specific measure/width)
        textView.font = NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        textView.textContainerInset = NSSize(width: 40, height: 40)
        
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
        }
    }
}
