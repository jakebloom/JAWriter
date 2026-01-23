import Foundation
import GoogleSignIn
import GoogleAPIClientForREST_Docs
import GoogleAPIClientForREST_Drive


@Observable
class GoogleManager {
    var currentUser: GIDGoogleUser? = nil
    var files: [GTLRDrive_File] = []
    var selectedDocument: GTLRDocs_Document? = nil
    var selectedTab: GTLRDocs_Tab? = nil
    
    @ObservationIgnored private let driveService = GTLRDriveService()
    @ObservationIgnored private let docsService = GTLRDocsService()
    
    // Scopes required for listing and editing
    let scopes = [
        kGTLRAuthScopeDriveMetadataReadonly,
        kGTLRAuthScopeDocsDocuments,
        kGTLRAuthScopeDrive,
    ]


    func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                // This is normal if the user has never signed in or has signed out
                print("No previous session to restore: \(error.localizedDescription)")
                return
            }

            self.currentUser = user
            self.driveService.authorizer = user?.fetcherAuthorizer
            self.docsService.authorizer = user?.fetcherAuthorizer
            self.listDocuments()
        }
    }

    func signIn() {
        guard let window = NSApplication.shared.windows.first else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: window, hint: nil, additionalScopes: scopes) { result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }

            self.currentUser = user
            self.driveService.authorizer = user.fetcherAuthorizer
            self.docsService.authorizer = user.fetcherAuthorizer
            self.listDocuments()
        }
    }
    
    func listDocuments() {
        let query = GTLRDriveQuery_FilesList.query()
        
        // Filter: Only show Google Docs that aren't in the trash
        query.q = "mimeType = 'application/vnd.google-apps.document' and trashed = false"
        query.fields = "files(id, name, modifiedTime)"
        

        driveService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error listing files: \(error.localizedDescription)")
                return
            }
            let fileList = result as? GTLRDrive_FileList
            self.files = fileList?.files ?? []
        }
    }
    
    func downloadDocument(fileId: String) {
        // 1. Construct the export URL for Markdown
        let query = GTLRDocsQuery_DocumentsGet.query(withDocumentId: fileId)
        query.includeTabsContent = true
        docsService.executeQuery(query) {_, result, error in
            if let error = error {
                print("Couldn't get document: \(error.localizedDescription)")
                return
            }
            
            guard let result = (result as? GTLRDocs_Document) else {
                return
            }
            
            self.selectedDocument = result
        }
    }
}
