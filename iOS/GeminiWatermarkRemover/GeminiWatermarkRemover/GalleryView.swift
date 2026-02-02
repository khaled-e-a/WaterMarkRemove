import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var historyManager: HistoryManager

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()

                VStack {
                    Text("History")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

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
                                                .frame(height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .glassCardStyle()
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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                Spacer()

                HStack(spacing: 20) {
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("Processed Image", image: Image(uiImage: image))) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }

                    Button(role: .destructive) {
                        historyManager.deleteItem(item)
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                            .font(.title)
                            .foregroundStyle(.red)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}
