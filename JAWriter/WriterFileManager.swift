import Foundation


@Observable
class WriterFileManager {
    @ObservationIgnored let fileManager = FileManager()
    var folder: URL? = nil
    var files: [URL] = []
    var selectedDocument: URL? = nil

    
    func listDocuments() {
        guard let folder = folder, folder.startAccessingSecurityScopedResource() else { return }

        do {
            let allFiles = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            files = allFiles.filter { !$0.lastPathComponent.hasPrefix(".") }
        } catch {
            print("Could not load folder: \(error.localizedDescription)")
        }
    }
    
    func getText() -> String {
        guard let selectedDocument = selectedDocument else { return "" }
        do {
            return try String(contentsOf: selectedDocument, encoding: .utf8)
        } catch {
            print("Error: \(error.localizedDescription)")
            return ""
        }
        
    }
    
    func writeFile(_ contents: String) {
        guard let selectedDocument = selectedDocument else { return }
        do {
            try contents.write(to: selectedDocument, atomically: true, encoding: .utf8)
        } catch {
            print("File write error: \(error.localizedDescription)")
        }
    }
    
    
}
