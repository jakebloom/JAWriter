//
//  MainTextView.swift
//  JAWriter
//
//  Created by Jake on 19/1/26.
//

import Foundation
import AppKit
import SwiftUI
import QuartzCore

class JAWriterMainTextView : NSTextView {
    var isFocusModeEnabled: Bool = false {
        didSet { updateFocusEffect() }
    }
    
    private var colorAnimationTimer: Timer?
    
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
        // Cancel any existing animation
        colorAnimationTimer?.invalidate()
        colorAnimationTimer = nil
        
        guard isFocusModeEnabled else {
            // Reset all text to primary color when focus mode is disabled
            let textStorage = self.textStorage!
            let fullRange = NSRange(location: 0, length: textStorage.length)
            textStorage.beginEditing()
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
            textStorage.endEditing()
            return
        }
        
        let textStorage = self.textStorage!
        let fullRange = NSRange(location: 0, length: textStorage.length)
        
        // Get the cursor position
        let cursorLocation = self.selectedRange().location
        
        // Find the paragraph range containing the cursor
        let paragraphRange = (self.string as NSString).paragraphRange(for: NSRange(location: cursorLocation, length: 0))
        
        // Get primary and secondary colors
        let primaryColor = NSColor.labelColor
        let secondaryColor = NSColor.secondaryLabelColor.withAlphaComponent(0.3)
        
        // Get current colors for interpolation
        var startColors: [Int: NSColor] = [:]
        textStorage.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { value, range, _ in
            if let color = value as? NSColor {
                for i in range.location..<(range.location + range.length) {
                    startColors[i] = color
                }
            }
        }
        
        // Animation parameters
        let duration: TimeInterval = 0.4
        let startTime = Date()
        
        // Animate color interpolation
        colorAnimationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / duration, 1.0)
            
            // Apply easeInOut easing function
            let easedProgress: CGFloat
            if progress < 0.5 {
                easedProgress = CGFloat(2 * progress * progress)
            } else {
                easedProgress = CGFloat(1 - pow(-2 * progress + 2, 2) / 2)
            }
            
            if progress >= 1.0 {
                // Animation complete - set final colors
                textStorage.beginEditing()
                textStorage.addAttribute(.foregroundColor, value: secondaryColor, range: fullRange)
                if paragraphRange.length > 0 {
                    textStorage.addAttribute(.foregroundColor, value: primaryColor, range: paragraphRange)
                }
                textStorage.endEditing()
                timer.invalidate()
                self.colorAnimationTimer = nil
            } else {
                // Interpolate colors
                textStorage.beginEditing()
                
                // Interpolate each character's color
                for i in 0..<textStorage.length {
                    let targetColor: NSColor
                    // Check if index is within paragraph range
                    if i >= paragraphRange.location && i < paragraphRange.location + paragraphRange.length {
                        targetColor = primaryColor
                    } else {
                        targetColor = secondaryColor
                    }
                    
                    let startColor = startColors[i] ?? NSColor.labelColor
                    let interpolatedColor = self.interpolateColor(from: startColor, to: targetColor, progress: easedProgress)
                    
                    textStorage.addAttribute(.foregroundColor, value: interpolatedColor, range: NSRange(location: i, length: 1))
                }
                
                textStorage.endEditing()
            }
        }
    }
    
    private func interpolateColor(from: NSColor, to: NSColor, progress: CGFloat) -> NSColor {
        // Convert both colors to the same color space (sRGB)
        let sRGBColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let fromCG = from.cgColor.converted(to: sRGBColorSpace, intent: .defaultIntent, options: nil),
              let toCG = to.cgColor.converted(to: sRGBColorSpace, intent: .defaultIntent, options: nil) else {
            // Fallback if conversion fails
            return progress < 0.5 ? from : to
        }
        
        let fromComponents = fromCG.components ?? [0, 0, 0, 1]
        let toComponents = toCG.components ?? [0, 0, 0, 1]
        
        let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * progress
        let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * progress
        let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * progress
        let a = (fromComponents.count > 3 ? fromComponents[3] : 1.0) + ((toComponents.count > 3 ? toComponents[3] : 1.0) - (fromComponents.count > 3 ? fromComponents[3] : 1.0)) * progress
        
        return NSColor(calibratedRed: r, green: g, blue: b, alpha: a)
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
        if textView.isFocusModeEnabled != isFocusMode {
            textView.isFocusModeEnabled = isFocusMode
        }
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
