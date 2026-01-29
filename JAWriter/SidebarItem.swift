//
//  SidebarItem.swift
//  JAWriter
//
//  Created by Jake on 24/1/26.
//

import SwiftUI

struct SidebarItem : View {
    @Environment(WriterFileManager.self) private var wFileManager
    var file: URL
    
    
    var body: some View {
        var isSelected: Bool {
            file == wFileManager.selectedDocument
        }
        HStack {
            Text(file.lastPathComponent)
                .bold()
                .padding(.leading, 4.0)
            Spacer()
        }
        .foregroundStyle(isSelected ? .white : .primary)
        .listRowBackground(isSelected ? Color.accentColor : Color.clear)
        .onTapGesture {
            wFileManager.selectedDocument = file
        }
    }
}

