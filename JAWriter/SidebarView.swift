//
//  SidebarView.swift
//  JAWriter
//
//  Created by Jake on 21/1/26.
//

import SwiftUI
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForREST_Docs
import GoogleSignIn


struct SidebarView: View {
    @Environment(GoogleManager.self) private var googleManager
    
    var body: some View {
        List {
            if let user = googleManager.currentUser {
                Text("Hello \(user.profile?.givenName ?? "")")
                    .font(.caption)
                
                Section("Google Docs") {
                    ForEach(googleManager.files, id: \.identifier) { file in
                        SidebarItem(file: file)
                            .environment(googleManager)
                    }
                }
            } else {
                Button("Sign in to Google") {
                    googleManager.signIn()
                }
            }
        }
    }
}
