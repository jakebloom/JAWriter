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
    
    init() {
        // Automatically check for a saved session on app launch
//        restoreSignIn()
    }

    func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                // This is normal if the user has never signed in or has signed out
                print("No previous session to restore: \(error.localizedDescription)")
                return
            }
            
            // Successfully restored! Update the UI
            DispatchQueue.main.async {
                self.currentUser = user
            }
        }
    }

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
