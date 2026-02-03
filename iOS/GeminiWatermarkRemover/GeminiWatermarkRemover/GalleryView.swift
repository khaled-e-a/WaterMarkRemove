import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var historyManager: HistoryManager
    @State private var showClearConfirmation = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()

                VStack {
                    HStack {
                        Text("History")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Spacer()

                        if !historyManager.items.isEmpty {
                            Button(action: { showClearConfirmation = true }) {
                                Image(systemName: "trash")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)

                    // Confirmation Dialog or Alert
                    .alert("Clear History", isPresented: $showClearConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete All", role: .destructive) {
                            historyManager.clearAll()
                        }
                    } message: {
                        Text("Are you sure you want to delete all history? This cannot be undone.")
                    }

                    if historyManager.items.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundStyle(.white.opacity(0.3))
                            Text("No history yet")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(historyManager.items) { item in
                                    if let image = historyManager.loadImage(for: item) {
                                        NavigationLink(destination: ImageDetailView(image: image, item: item)) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .frame(height: 150)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                // .glassCardStyle() // Removing this if it adds external padding, or applying it carefully
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ImageDetailView: View {
    @EnvironmentObject var historyManager: HistoryManager
    @Environment(\.dismiss) var dismiss

    let image: UIImage
    let item: HistoryItem

    // Alert state for Save action
    @State private var showingSaveAlert = false
    @State private var saveMessage = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ZStack(alignment: .top) {
                // Layer 1: Image (Centered)
                VStack {
                    Spacer()
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    Spacer()
                }

                // Layer 2: Floating Action Buttons (Top)
                HStack(spacing: 30) {
                    // Save Button
                    Button(action: saveImageToPhotos) {
                        VStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.title2)
                            Text("Save")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white)
                    }

                    // Share Button
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("Processed Image", image: Image(uiImage: image))) {
                        VStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                            Text("Share")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white)
                    }

                    // Delete Button
                    Button(role: .destructive) {
                        historyManager.deleteItem(item)
                        dismiss()
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "trash")
                                .font(.title2)
                            Text("Delete")
                                .font(.caption2)
                        }
                        .foregroundStyle(.red)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color.black.opacity(0.6))
                .clipShape(Capsule())
                .padding(.top, 50) // More padding from top safe area
            }
        }
        .alert("Save Image", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveMessage)
        }
    }

    func saveImageToPhotos() {
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            self.saveMessage = "Image saved to Photos!"
            self.showingSaveAlert = true
        }
        imageSaver.errorHandler = { error in
            self.saveMessage = "Error saving image: \(error.localizedDescription)"
            self.showingSaveAlert = true
        }
        imageSaver.writeToPhotoAlbum(image: image)
    }
}
