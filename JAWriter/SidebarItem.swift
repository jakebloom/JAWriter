//
//  SidebarItem.swift
//  JAWriter
//
//  Created by Jake on 24/1/26.
//

import SwiftUI
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForREST_Docs

struct SidebarItem : View {
    @Environment(GoogleManager.self) private var googleManager
    @State var file: GTLRDrive_File
    
    
    var body: some View {
        let isExpanded = Binding<Bool>(
            get: {
                googleManager.selectedDocument != nil && googleManager.selectedDocument?.documentId == file.identifier
            },
            set: {_ in }
        )
        DisclosureGroup(isExpanded: isExpanded, content: {
            if let tabs: [GTLRDocs_Tab] = googleManager.selectedDocument?.tabs {
                if tabs.count > 1 {
                    ForEach(tabs, id: \.tabProperties?.tabId) { tab in
                        Text(tab.tabProperties?.title ?? "")
                            .onTapGesture {
                                googleManager.selectedTab = tab
                            }
                    }
                }
            }
        }, label: {
            Label(file.name ?? "Untitled", systemImage: "doc.text")
        }).onTapGesture {
            guard let fileId = file.identifier else { return }
            googleManager.downloadDocument(fileId: fileId)
        }
    }
}

