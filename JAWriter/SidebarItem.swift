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
                
                ForEach(tabs, id: \.tabProperties?.tabId) { tab in
                    var isSelected: Bool {
                        googleManager.selectedTab?.tabProperties?.tabId == tab.tabProperties?.tabId
                    }
                    HStack {
                        Text(tab.tabProperties?.title ?? "")
                        Spacer()
                    }
                    .onTapGesture {
                        googleManager.selectedTab = tab
                    }
                    .foregroundStyle(isSelected ? .white : .primary)
                    .listRowBackground(isSelected ? Color.accentColor : Color.clear)
                }
            }
        }, label: {
            HStack {
                Text(file.name ?? "Untitled")
                    .bold()
                    .padding(.leading, 4.0)
                Spacer()
            }
            .onTapGesture {
                guard let fileId = file.identifier else { return }
                googleManager.downloadDocument(fileId: fileId)
            }
        })
    }
}

