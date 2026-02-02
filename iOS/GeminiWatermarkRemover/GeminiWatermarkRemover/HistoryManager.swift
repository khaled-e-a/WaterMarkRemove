import Foundation
import UIKit
import Combine

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let date: Date
    let filename: String
}

class HistoryManager: ObservableObject {
    @Published var items: [HistoryItem] = []

    private let historyFileName = "history.json"
    private let imagesDirectoryName = "ProcessedImages"

    init() {
        loadHistory()
    }

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var imagesDirectory: URL {
        documentsDirectory.appendingPathComponent(imagesDirectoryName)
    }

    private var historyFileUrl: URL {
        documentsDirectory.appendingPathComponent(historyFileName)
    }

    func saveImage(_ image: UIImage) {
        // Ensure directory exists
        if !FileManager.default.fileExists(atPath: imagesDirectory.path) {
            try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }

        let id = UUID()
        let filename = "\(id.uuidString).jpg"
        let fileUrl = imagesDirectory.appendingPathComponent(filename)

        if let data = image.jpegData(compressionQuality: 0.9) {
            do {
                try data.write(to: fileUrl)
                let item = HistoryItem(id: id, date: Date(), filename: filename)
                items.insert(item, at: 0) // Newest first
                saveIndex()
            } catch {
                print("Failed to save image: \(error)")
            }
        }
    }

    func loadImage(for item: HistoryItem) -> UIImage? {
        let fileUrl = imagesDirectory.appendingPathComponent(item.filename)
        return UIImage(contentsOfFile: fileUrl.path)
    }

    func deleteItem(_ item: HistoryItem) {
        // Remove from list
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }

        // Remove file
        let fileUrl = imagesDirectory.appendingPathComponent(item.filename)
        try? FileManager.default.removeItem(at: fileUrl)

        saveIndex()
    }

    private func saveIndex() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: historyFileUrl)
        } catch {
            print("Failed to save history index: \(error)")
        }
    }

    private func loadHistory() {
        do {
            let data = try Data(contentsOf: historyFileUrl)
            items = try JSONDecoder().decode([HistoryItem].self, from: data)
            // Sort by date descending
            items.sort(by: { $0.date > $1.date })
        } catch {
            // No history found or error, just ignore
            items = []
        }
    }
}
