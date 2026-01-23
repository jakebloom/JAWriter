//
//  TabListView.swift
//  JAWriter
//
//  Created by Jake on 23/1/26.
//
import SwiftUI
import GoogleAPIClientForREST_Docs

struct TabListView : View {
    @Environment(GoogleManager.self) var googleManager

    var body: some View {
        if let doc = googleManager.selectedDocument {
            ForEach(doc.tabs ?? [], id: \.tabProperties?.tabId) { tab in
                Label {
                    Text(tab.tabProperties?.title ?? "")
                } icon: {
                    Text(tab.tabProperties?.iconEmoji ?? "")
                }
                .onTapGesture {
                    googleManager.selectedTab = tab
                }
            }
        } else {
            EmptyView()
        }
    }
}
