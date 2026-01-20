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
    @State private var isFocusMode: Bool = true

    var body: some View {
        WriterEditor(text: text, isFocusMode: isFocusMode)
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
