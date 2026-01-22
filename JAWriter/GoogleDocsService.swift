//
//  GoogleDocsService.swift
//  JAWriter
//
//  Created by Jake on 21/1/26.
//

import GoogleAPIClientForREST_Drive
import GoogleSignIn

class GoogleDocsService {
    private let driveService = GTLRDriveService()
    
    init(user: GIDGoogleUser) {
        // Link the Google Sign-In credentials to the Drive Service
        self.driveService.authorizer = user.fetcherAuthorizer
    }

    func listDocuments(completion: @escaping ([GTLRDrive_File]?) -> Void) {
        let query = GTLRDriveQuery_FilesList.query()
        
        // Filter: Only show Google Docs that aren't in the trash
        query.q = "mimeType = 'application/vnd.google-apps.document' and trashed = false"
        query.fields = "files(id, name, modifiedTime)"

        driveService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error listing files: \(error.localizedDescription)")
                completion(nil)
                return
            }
            let fileList = result as? GTLRDrive_FileList
            completion(fileList?.files)
        }
    }
    
    func downloadMarkdown(fileId: String, completion: @escaping (String?) -> Void) {
        // 1. Construct the export URL for Markdown
        let urlString = "https://www.googleapis.com/drive/v3/files/\(fileId)/export?mimeType=text/markdown"
        guard let url = URL(string: urlString) else { return }
        
        // 2. Use the authorizer already attached to your driveService
        let fetcher = driveService.fetcherService.fetcher(with: url)
        
        fetcher.beginFetch { data, error in
            if let error = error {
                print("Export failed: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // 3. Convert the downloaded data into a UTF-8 string
            if let data = data, let markdown = String(data: data, encoding: .utf8) {
                completion(markdown)
            }
        }
    }
}
