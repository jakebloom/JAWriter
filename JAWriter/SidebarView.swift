//
//  SidebarView.swift
//  JAWriter
//
//  Created by Jake on 21/1/26.
//

import SwiftUI
internal import UniformTypeIdentifiers


struct SidebarView: View {
    @Environment(WriterFileManager.self) private var wFileManager
    @State private var isImporting = false
    
    var body: some View {
        List {
            if wFileManager.folder != nil {
                Section {
                    ForEach(wFileManager.files, id: \.absoluteString) { file in
                        SidebarItem(file: file)
                            .environment(wFileManager)
                    }
                }
            } else {
                Button("Open Folder") {
                    isImporting = true
                }
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.folder]) { result in
                    switch result {
                    case .success(let url):
                        wFileManager.setFolderUrl(url)
                    case .failure(let error):
                        print("File import error \(error.localizedDescription)")
                    }
                    isImporting = false
                }
            }
        }
    }
}
