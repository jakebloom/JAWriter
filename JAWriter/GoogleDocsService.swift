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
}
