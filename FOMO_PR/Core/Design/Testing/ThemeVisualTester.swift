import SwiftUI
import UIKit

/// A utility for creating visual snapshots of UI components for design system validation.
/// This tool allows developers to visually compare UI before and after design system changes.
public struct ThemeVisualTester {
    
    /// Creates a snapshot image of a SwiftUI view
    /// - Parameters:
    ///   - view: The SwiftUI view to capture
    ///   - size: Size of the capture frame
    ///   - colorScheme: Light or dark mode
    ///   - completion: Callback with the generated UIImage
    public static func snapshot<T: View>(
        _ view: T,
        size: CGSize = CGSize(width: 390, height: 844), // iPhone 14 size
        colorScheme: ColorScheme = .dark,
        completion: @escaping (UIImage?) -> Void
    ) {
        let controller = UIHostingController(
            rootView: view
                .frame(width: size.width, height: size.height)
                .environment(\.colorScheme, colorScheme)
        )
        let view = controller.view
        
        view?.frame = CGRect(origin: .zero, size: size)
        view?.backgroundColor = UIColor(FOMOTheme.Colors.background)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        DispatchQueue.main.async {
            let image = renderer.image { _ in
                view?.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
            }
            completion(image)
        }
    }
    
    /// Save a snapshot image to the Documents directory
    /// - Parameters:
    ///   - image: The image to save
    ///   - name: Filename without extension
    ///   - completion: Callback with the file URL if successful
    public static func saveSnapshot(_ image: UIImage, name: String, completion: @escaping (URL?) -> Void) {
        guard let data = image.pngData() else {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = "\(name)_\(Int(Date().timeIntervalSince1970)).png"
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            do {
                try data.write(to: fileURL)
                DispatchQueue.main.async {
                    completion(fileURL)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    /// Generate snapshots for a set of key app screens to validate design system changes
    /// - Parameters:
    ///   - outputDirectory: Directory to save snapshots
    ///   - completion: Callback with array of saved image URLs
    public static func generateDesignSystemSnapshots(
        outputDirectory: URL? = nil,
        completion: @escaping ([URL]) -> Void
    ) {
        var savedImageURLs: [URL] = []
        let group = DispatchGroup()
        
        // Get output directory
        let directory = outputDirectory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DesignSystemSnapshots_\(Int(Date().timeIntervalSince1970))", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        // Venue screens
        group.enter()
        snapshot(ThemeShowcaseView()) { image in
            guard let image = image else {
                group.leave()
                return
            }
            
            saveSnapshot(image, name: "ThemeShowcase") { url in
                if let url = url {
                    savedImageURLs.append(url)
                }
                group.leave()
            }
        }
        
        // Components overview
        group.enter()
        snapshot(ComponentsDemoView()) { image in
            guard let image = image else {
                group.leave()
                return
            }
            
            saveSnapshot(image, name: "ComponentsOverview") { url in
                if let url = url {
                    savedImageURLs.append(url)
                }
                group.leave()
            }
        }
        
        // Typography overview
        group.enter()
        snapshot(TypographyDemoView()) { image in
            guard let image = image else {
                group.leave()
                return
            }
            
            saveSnapshot(image, name: "TypographyOverview") { url in
                if let url = url {
                    savedImageURLs.append(url)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(savedImageURLs)
        }
    }
    
    /// Compare two images for differences
    /// - Parameters:
    ///   - image1: First image
    ///   - image2: Second image
    ///   - threshold: Difference threshold (0.0-1.0)
    /// - Returns: Difference percentage and comparison image
    public static func compareSnapshots(_ image1: UIImage, _ image2: UIImage, threshold: CGFloat = 0.01) -> (difference: CGFloat, comparisonImage: UIImage?) {
        guard let cgImage1 = image1.cgImage, let cgImage2 = image2.cgImage else {
            return (1.0, nil)
        }
        
        let width = min(cgImage1.width, cgImage2.width)
        let height = min(cgImage1.height, cgImage2.height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return (1.0, nil)
        }
        
        context.draw(cgImage1, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data1 = context.data else {
            return (1.0, nil)
        }
        
        guard let context2 = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return (1.0, nil)
        }
        
        context2.draw(cgImage2, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data2 = context2.data else {
            return (1.0, nil)
        }
        
        // Compare the pixel data
        let data1Ptr = data1.bindMemory(to: UInt32.self, capacity: width * height)
        let data2Ptr = data2.bindMemory(to: UInt32.self, capacity: width * height)
        
        let diffContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )!
        
        var differentPixels = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = y * width + x
                let pixel1 = data1Ptr[offset]
                let pixel2 = data2Ptr[offset]
                
                if pixel1 != pixel2 {
                    differentPixels += 1
                    // Mark different pixels in red
                    diffContext.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
                    diffContext.fill(CGRect(x: x, y: y, width: 1, height: 1))
                } else {
                    // Copy original pixel
                    let r = CGFloat((pixel1 >> 16) & 0xFF) / 255.0
                    let g = CGFloat((pixel1 >> 8) & 0xFF) / 255.0
                    let b = CGFloat(pixel1 & 0xFF) / 255.0
                    diffContext.setFillColor(CGColor(red: r, green: g, blue: b, alpha: 1))
                    diffContext.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
        
        let difference = CGFloat(differentPixels) / CGFloat(width * height)
        return (difference, UIImage(cgImage: diffContext.makeImage()!))
    }
}

#if DEBUG
struct ThemeVisualTesterDemo: View {
    @State private var beforeImage: UIImage?
    @State private var afterImage: UIImage?
    @State private var comparisonImage: UIImage?
    @State private var difference: CGFloat = 0
    
    var body: some View {
        VStack {
            Text("Theme Visual Testing Demo")
                .font(FOMOTheme.Typography.headlineMedium)
                .padding()
            
            HStack {
                VStack {
                    Text("Before")
                        .font(FOMOTheme.Typography.caption1)
                    
                    if let beforeImage = beforeImage {
                        Image(uiImage: beforeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    } else {
                        Color.gray
                            .frame(height: 200)
                    }
                }
                
                VStack {
                    Text("After")
                        .font(FOMOTheme.Typography.caption1)
                    
                    if let afterImage = afterImage {
                        Image(uiImage: afterImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    } else {
                        Color.gray
                            .frame(height: 200)
                    }
                }
            }
            
            if let comparisonImage = comparisonImage {
                Text("Comparison (Diff: \(Int(difference * 100))%)")
                    .font(FOMOTheme.Typography.caption1)
                
                Image(uiImage: comparisonImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            }
            
            Button("Generate Test Images") {
                generateTestImages()
            }
            .padding()
        }
        .padding()
    }
    
    private func generateTestImages() {
        // Generate "before" image
        let beforeView = Text("Sample Text")
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
        
        ThemeVisualTester.snapshot(beforeView) { image in
            self.beforeImage = image
            
            // Generate "after" image with slightly different styling
            let afterView = Text("Sample Text")
                .font(.system(size: 22)) // Different font size
                .foregroundColor(.white)
                .padding()
                .background(Color.purple) // Different color
                .cornerRadius(12) // Different corner radius
            
            ThemeVisualTester.snapshot(afterView) { afterImage in
                self.afterImage = afterImage
                
                if let before = self.beforeImage, let after = self.afterImage {
                    let comparison = ThemeVisualTester.compareSnapshots(before, after)
                    self.comparisonImage = comparison.comparisonImage
                    self.difference = comparison.difference
                }
            }
        }
    }
}

struct ThemeVisualTester_Previews: PreviewProvider {
    static var previews: some View {
        ThemeVisualTesterDemo()
    }
}
#endif 