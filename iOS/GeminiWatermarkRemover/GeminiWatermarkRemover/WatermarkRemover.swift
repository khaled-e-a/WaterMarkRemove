import UIKit
import CoreGraphics

class WatermarkRemover {

    // Constants from blendModes.js
    private let ALPHA_THRESHOLD: Float = 0.002
    private let MAX_ALPHA: Float = 0.99
    private let LOGO_VALUE: Float = 255.0

    // Cached alpha maps
    private var alphaMaps: [Int: [Float]] = [:]

    static let shared = WatermarkRemover()

    private init() {
        // Preload alpha maps if possible, or load on demand
    }

    enum WatermarkError: Error {
        case imageProcessingFailed
        case assetMissing
    }

    struct WatermarkConfig {
        let logoSize: Int
        let marginRight: Int
        let marginBottom: Int
    }

    struct WatermarkPosition {
        let x: Int
        let y: Int
        let width: Int
        let height: Int
    }

    // MARK: - Public API

    func removeWatermark(from image: UIImage) async throws -> UIImage {
        // 1. Detect Config
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let config = detectWatermarkConfig(width: width, height: height)
        let position = calculateWatermarkPosition(width: width, height: height, config: config)

        // 2. Get Alpha Map
        let alphaMap = try await getAlphaMap(size: config.logoSize)

        // 3. Process Image
        return try await processImage(image, alphaMap: alphaMap, position: position)
    }

    // MARK: - Internal Logic

    private func detectWatermarkConfig(width: Int, height: Int) -> WatermarkConfig {
        if width > 1024 && height > 1024 {
            return WatermarkConfig(logoSize: 96, marginRight: 64, marginBottom: 64)
        } else {
            return WatermarkConfig(logoSize: 48, marginRight: 32, marginBottom: 32)
        }
    }

    private func calculateWatermarkPosition(width: Int, height: Int, config: WatermarkConfig) -> WatermarkPosition {
        return WatermarkPosition(
            x: width - config.marginRight - config.logoSize,
            y: height - config.marginBottom - config.logoSize,
            width: config.logoSize,
            height: config.logoSize
        )
    }

    private func getAlphaMap(size: Int) async throws -> [Float] {
        if let cached = alphaMaps[size] {
            return cached
        }

        // let assetName = "bg_\(size).png" // Unused variable removed
        // Since we copied assets, we need to load them from bundle or provided path
        // Assuming they are in the Bundle for a real app, or we read from the file system path we set up in "Assets"
        // For this generated code, I'll assume standard Bundle usage or efficient loading.
        // However, since we are in a hybrid environment, I will try to load from the 'Assets' folder in the current directory if bundle fails.

        var image: UIImage?

        // Try loading from Bundle (Standard iOS)
        if let bundleImage = UIImage(named: "bg_\(size)") {
             image = bundleImage
        } else {
             // Fallback: Try loading from local path (Simulator/Dev environment)
             let currentDir = FileManager.default.currentDirectoryPath
             let path = URL(fileURLWithPath: currentDir).appendingPathComponent("Assets/bg_\(size).png").path
             image = UIImage(contentsOfFile: path)
        }

        guard let bgImage = image, let cgImage = bgImage.cgImage else {
            throw WatermarkError.assetMissing
        }

        let map = calculateAlphaMap(from: cgImage)
        alphaMaps[size] = map
        return map
    }

    // Port of alphaMap.js
    private func calculateAlphaMap(from cgImage: CGImage) -> [Float] {
        let width = cgImage.width
        let height = cgImage.height
        var alphaMap = [Float](repeating: 0, count: width * height)

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow

        var pixelData = [UInt8](repeating: 0, count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // Use standard RGBA
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return alphaMap
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        for i in 0..<alphaMap.count {
            let offset = i * 4
            let r = Float(pixelData[offset])
            let g = Float(pixelData[offset + 1])
            let b = Float(pixelData[offset + 2])

            // maxChannel / 255.0
            let maxChannel = max(r, max(g, b))
            alphaMap[i] = maxChannel / 255.0
        }

        return alphaMap
    }

    // Port of blendModes.js
    private func processImage(_ image: UIImage, alphaMap: [Float], position: WatermarkPosition) async throws -> UIImage {
        guard let cgImage = image.cgImage else { throw WatermarkError.imageProcessingFailed }

        let width = cgImage.width
        let height = cgImage.height

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow

        var pixelData = [UInt8](repeating: 0, count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            throw WatermarkError.imageProcessingFailed
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Loop bounds
        let startX = position.x
        let startY = position.y
        let w = position.width
        let h = position.height

        // Ensure bounds are safe
        guard startX >= 0, startY >= 0, startX + w <= width, startY + h <= height else {
             // Watermark area outside image bounds? Return original if so.
             return image
        }

        for row in 0..<h {
            for col in 0..<w {
                // Image index
                let imgX = startX + col
                // Note: CGContext coordinate system vs Image data buffer
                // The buffer is usually top-left origin if we just read it linearly,
                // BUT drawImage flips Y in some contexts.
                // However, creating a context with user allocated buffer and NO transform behaves like a bitmap (Top-Left 0,0).
                let imgY = startY + row // Top-down

                let imgIdx = (imgY * width + imgX) * 4

                // Alpha map index
                let alphaIdx = row * w + col

                var alpha = alphaMap[alphaIdx]

                if alpha < ALPHA_THRESHOLD { continue }

                alpha = min(alpha, MAX_ALPHA)
                let oneMinusAlpha = 1.0 - alpha

                // RGB channels
                for c in 0..<3 {
                    let watermarked = Float(pixelData[imgIdx + c])

                    // original = (watermarked - alpha * LOGO_VALUE) / oneMinusAlpha
                    let original = (watermarked - alpha * LOGO_VALUE) / oneMinusAlpha

                    // Clip [0, 255]
                    let pinned = max(0, min(255, round(original)))

                    pixelData[imgIdx + c] = UInt8(pinned)
                }
            }
        }

        guard let resultCGImage = context.makeImage() else {
            throw WatermarkError.imageProcessingFailed
        }

        return UIImage(cgImage: resultCGImage)
    }
}
