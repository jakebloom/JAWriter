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
        if wFileManager.folder != nil {
            VStack {
                List {
                    ForEach(wFileManager.files, id: \.absoluteString) { file in
                        SidebarItem(file: file)
                            .environment(wFileManager)
                    }.onMove { from, to in
                        print("FROM \(from) TO \(to)")
                    }
                }
                HStack {
                    Button {
                        wFileManager.listDocuments()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    Spacer()
                    Button {
                        wFileManager.closeFolder()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .background(.ultraThinMaterial)
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
    
    func move(from source: IndexSet, to destination: Int) {
        
    }
}
