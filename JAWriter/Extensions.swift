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
}
