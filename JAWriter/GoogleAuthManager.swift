import Foundation
import GoogleSignIn
import GoogleAPIClientForREST_Docs
import GoogleAPIClientForREST_Drive

@Observable
class GoogleAuthManager {
    static let shared = GoogleAuthManager()
    var currentUser: GIDGoogleUser?
    
    // Scopes required for listing and editing
    let scopes = [
        kGTLRAuthScopeDriveMetadataReadonly,
        kGTLRAuthScopeDocsDocuments
    ]

    func signIn() {
        guard let window = NSApplication.shared.windows.first else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: window, hint: nil, additionalScopes: scopes) { result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            self.currentUser = result?.user
        }
    }
}
