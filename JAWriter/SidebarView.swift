//
//  SidebarView.swift
//  JAWriter
//
//  Created by Jake on 21/1/26.
//

import SwiftUI
import GoogleAPIClientForREST_Drive
import GoogleSignIn


struct SidebarView: View {
    @State private var authManager = GoogleAuthManager.shared
    @State private var driveFiles: [GTLRDrive_File] = []
    
    var body: some View {
        List {
            if let user = authManager.currentUser {
                Text("Signed in as \(user.profile?.email ?? "User")")
                    .font(.caption)
                
                Section("Google Docs") {
                    ForEach(driveFiles, id: \.identifier) { file in
                        Label(file.name ?? "Untitled", systemImage: "doc.text")
                    }
                }
            } else {
                Button("Sign in to Google") {
                    authManager.signIn()
                }
            }
        }
        .onAppear {
            if let user = authManager.currentUser {
                fetchFiles(for: user)
            }
        }
        // Refresh when user signs in
        .onChange(of: authManager.currentUser) { _, newUser in
            if let user = newUser { fetchFiles(for: user) }
        }
    }

    func fetchFiles(for user: GIDGoogleUser) {
        GoogleDocsService(user: user).listDocuments { files in
            if let files = files {
                self.driveFiles = files
            }
        }
    }
}
