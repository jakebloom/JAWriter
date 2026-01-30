//
//  Extensions.swift
//  JAWriter
//
//  Created by Jake on 21/1/26.
//

import Foundation

extension String {
    var wordCount: Int {
        let charSet = CharacterSet.alphanumerics.inverted
        let words = self.components(separatedBy: charSet)
        return words.filter { !$0.isEmpty }.count
    }
    
    func getSentence(_ range: NSRange) -> NSRange? {
        guard let range = Range(range, in: self) else { return nil }
        
        let segments = self.split(omittingEmptySubsequences: false) { char in
            char == "." || char == "?" || char == "!" || char.isNewline
        }
        
        if let target = segments.first(where: { $0.startIndex <= range.lowerBound && $0.endIndex >= range.upperBound }) {
            return NSRange(target.startIndex...target.endIndex, in: self)
        }
        return nil
    }
}
