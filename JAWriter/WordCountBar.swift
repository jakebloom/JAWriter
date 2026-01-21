//
//  WordCountBar.swift
//  JAWriter
//
//  Created by Jake on 21/1/26.
//

import SwiftUI

struct WordCountBar: View {
    let count: Int
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 15) {
                Text("\(count) Words")
                Text("\(count / 200) Min")
            }
            .font(.system(.caption, design: .monospaced))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .cornerRadius(4)
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}
