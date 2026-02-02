import Foundation
import SwiftUI

@Observable
class WriterFileManager {
    @ObservationIgnored let fileManager = FileManager()
    var folder: URL? = nil
    var files: [URL] = []
    var selectedDocument: URL? = nil
    
    init(folder: URL? = nil, files: [URL] = [], selectedDocument: URL? = nil) {
        self.files = files
        self.selectedDocument = selectedDocument
        self.folder = hydrateFolderUrl()
    }

    
    func listDocuments() {
        guard let folder = folder, folder.startAccessingSecurityScopedResource() else { return }

        do {
            let allFiles = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            files = allFiles.filter { !$0.lastPathComponent.hasPrefix(".") }
        } catch {
            print("Could not load folder: \(error.localizedDescription)")
        }
        folder.stopAccessingSecurityScopedResource()

        let savedOrder = UserDefaults.standard.stringArray(forKey: folder.path()) ?? []
        files = files.sorted { url1, url2 in
            let name1 = url1.lastPathComponent
            let name2 = url2.lastPathComponent
            
            let index1 = savedOrder.firstIndex(of: name1) ?? Int.max
            let index2 = savedOrder.firstIndex(of: name2) ?? Int.max
            
            return index1 < index2
        }
    }
    
    func getText() -> String {
        guard let selectedDocument = selectedDocument, folder?.startAccessingSecurityScopedResource() == true else { return "" }
        var data = ""
        do {
            data = try String(contentsOf: selectedDocument, encoding: .utf8)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        folder?.stopAccessingSecurityScopedResource()
        return data
    }
    
    func setFolderUrl(_ url: URL) {
        self.folder = url
        listDocuments()
        guard url.startAccessingSecurityScopedResource() else { return }
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: "folderBookmark")
        } catch {
            print("Failed to create bookmark: \(error)")
        }
        url.stopAccessingSecurityScopedResource()
    }
    
    func hydrateFolderUrl() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "folderBookmark") else {
            return nil
        }
        var isStale = false

        do {
            // Resolve the data back into a URL
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            if isStale {
                let bookmarkData = try url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                UserDefaults.standard.set(bookmarkData, forKey: "folderBookmark")
            }
            return url
        } catch {
            print("Error resolving bookmark: \(error)")
        }
        return nil
    }
    
    func writeFile(_ contents: String) {
        guard let selectedDocument = selectedDocument, folder?.startAccessingSecurityScopedResource() == true else { return }
        do {
            try contents.write(to: selectedDocument, atomically: true, encoding: .utf8)
        } catch {
            print("File write error: \(error.localizedDescription)")
        }
        folder?.stopAccessingSecurityScopedResource()
    }
    
    func closeFolder() {
        folder = nil
        files = []
        selectedDocument = nil
        UserDefaults.standard.set(nil, forKey: "folderBookmark")
    }
    
    func moveFile(from: IndexSet, to: Int) {
        guard let folder = folder else { return }
        files.move(fromOffsets: from, toOffset: to)
        
        let fileNames = files.map { $0.lastPathComponent }
        UserDefaults.standard.set(fileNames, forKey: folder.path())
    }
    
    
}
