import SwiftUI
import PhotosUI

struct HomeView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var historyManager: HistoryManager

    @State private var selectedItem: PhotosPickerItem?
    @State private var inputImage: UIImage?
    @State private var outputImage: UIImage?
    @State private var isProcessing: Bool = false
    @State private var showPaywall: Bool = false
    @State private var errorMessage: String?
    @State private var showingError: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()

                VStack(spacing: 20) {
                    // Title
                    Text("Gemini Remover")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 20)

                    // Subscription Status Badge
                    if subscriptionManager.isSubscribed {
                        Text("PRO UNLOCKED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .foregroundStyle(.black)
                            .clipShape(Capsule())
                    } else {
                        HStack(spacing: 8) {
                            Text("\(subscriptionManager.canRemoveWatermark ? "1" : "0") Free Removal Left")
                                .font(.caption)
                                .foregroundStyle(.gray)

                            Button(action: { showPaywall = true }) {
                                Text("Get Pro")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.yellow.opacity(0.8))
                                    .foregroundStyle(.black)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    // Main Content Area
                    ScrollView {
                        VStack(spacing: 24) {
                            // Image Display Area
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.05))
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    .frame(height: 350)

                                if let outputImage = outputImage {
                                    Image(uiImage: outputImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 350)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .overlay(
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundStyle(.green)
                                                        .font(.title)
                                                        .padding()
                                                }
                                            }
                                        )
                                } else if let inputImage = inputImage {
                                    Image(uiImage: inputImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 350)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 48))
                                            .foregroundStyle(.white.opacity(0.6))
                                        Text("Tap to Select Image")
                                            .font(.headline)
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                }

                                if isProcessing {
                                    ZStack {
                                        Color.black.opacity(0.4)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.5)
                                    }
                                    .frame(height: 350)
                                }
                            }
                            .onTapGesture {
                                // Only trigger picker if no image is selected or user wants to change
                                // But PhotosPicker handles the tap via the overlay usually.
                            }
                            .overlay(
                                // Invisible picker over the area if empty
                                Group {
                                    if inputImage == nil {
                                        PhotosPicker(selection: $selectedItem, matching: .images) {
                                            Color.clear
                                        }
                                    }
                                }
                            )

                            // Actions
                            if inputImage != nil {
                                HStack(spacing: 16) {
                                    // Change Image Button
                                    PhotosPicker(selection: $selectedItem, matching: .images) {
                                        HStack {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                            Text("Change")
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .foregroundStyle(.white)
                                    }

                                    if outputImage == nil {
                                        // Remove Button
                                        Button(action: removeWatermark) {
                                            HStack {
                                                Image(systemName: "wand.and.stars")
                                                Text("Magic Remove")
                                            }
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(
                                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .foregroundStyle(.white)
                                        }
                                        .disabled(isProcessing)
                                    } else {
                                        // Save/Share Button
                                        HStack(spacing: 12) {
                                            // Save Button
                                            Button(action: saveToPhotos) {
                                                HStack {
                                                    Image(systemName: "square.and.arrow.down")
                                                    Text("Save")
                                                }
                                                .fontWeight(.bold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.blue)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .foregroundStyle(.white)
                                            }

                                            // Share Button
                                            ShareLink(item: Image(uiImage: outputImage!), preview: SharePreview("Cleaned Image", image: Image(uiImage: outputImage!))) {
                                                HStack {
                                                    Image(systemName: "square.and.arrow.up")
                                                    Text("Share")
                                                }
                                                .fontWeight(.bold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.green)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .foregroundStyle(.white)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            // Navigation Bar invisible or styled
            .navigationBarHidden(true)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        self.inputImage = uiImage
                        self.outputImage = nil // Reset output on new selection
                    }
                }
            }
        }
    }

    // Logic
    func removeWatermark() {
        guard let input = inputImage else { return }

        // Subscription Check
        subscriptionManager.checkDailyLimit()
        if !subscriptionManager.canRemoveWatermark {
            showPaywall = true
            return
        }

        isProcessing = true

        Task {
            do {
                // Delay for UI smoothness
                try await Task.sleep(nanoseconds: 500_000_000)

                let processed = try await WatermarkRemover.shared.removeWatermark(from: input)

                await MainActor.run {
                    self.outputImage = processed
                    self.isProcessing = false
                    self.subscriptionManager.incrementDailyUsage()
                    self.historyManager.saveImage(processed)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to process image. Please try again."
                    self.showingError = true
                    self.isProcessing = false
                }
            }
        }
    }


    func saveToPhotos() {
        guard let image = outputImage else { return }
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            self.errorMessage = "Image saved to Photos!"
            self.showingError = true
        }
        imageSaver.errorHandler = { error in
            self.errorMessage = "Error saving image: \(error.localizedDescription)"
            self.showingError = true
        }
        imageSaver.writeToPhotoAlbum(image: image)
    }
}

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}

// Simple Paywall View embedded
struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        ZStack {
            GradientBackground()
            VStack(spacing: 30) {
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
                    .shadow(color: .orange, radius: 10)

                Text("Upgrade to Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Unlock unlimited daily removals and support independent development.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            try? await subscriptionManager.purchase()
                            dismiss()
                        }
                    }) {
                        Text("Subscribe for $1.99 / Month")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }

                    Button("Restore Purchases") {
                        Task {
                             await subscriptionManager.updateSubscriptionStatus()
                             dismiss()
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                }
                .padding()

                Spacer()
                Button("Maybe Later") {
                   dismiss()
                }
                .foregroundStyle(.white.opacity(0.5))
                .padding(.bottom)
            }
        }
    }
}
