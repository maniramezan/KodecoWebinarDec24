import PhotosUI
import SwiftUI
import Vision

struct CreateMLView: View {
    @State private var image = Image(systemName: "person.crop.square.badge.camera")
    @State private var isShowingImagePicker = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var recognizedEmotionText = Text("")
    private let request: CoreMLRequest
    
    init() {
        guard let modelContainer = try? CoreMLModelContainer(model: FaceEmotionRecognizer().model) else {
            fatalError("Failed to load Core ML model.")
        }
        request = CoreMLRequest(model: modelContainer)
    }
    
    var body: some View {
        Menu {
            VStack {
                Button {
                    isShowingImagePicker.toggle()
                } label: {
                    Label("Photo album", systemImage: "photo")
                }
            }
        } label: {
            VStack {
                image
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .foregroundStyle(Color.gray.opacity(0.6))
                    .border(Color.secondary.opacity(0.4), width: 5)
                    .cornerRadius(10)
                recognizedEmotionText
            }
        }
        .padding()
        .photosPicker(isPresented: $isShowingImagePicker, selection: $selectedImage, matching: .images)
        .onChange(of: selectedImage, initial: false) { _,newValue  in
            Task {
                guard let newValue,
                      let imageData = try? await newValue.loadTransferable(type: Data.self) else {
                    logger.error("Error loading image data from photo library")
                    recognizedEmotionText = Text("Failed to recovnized the emotion")
                    return
                }
                        
                guard let image = UIImage(data: imageData),
                      let detectedEmotion = try? await runCreateML(on: image) else {
                    logger.error("Error running CeateML model")
                    recognizedEmotionText = Text("Failed to recovnize the emotion")
                    return
                }
                self.image = Image(uiImage: image)
                recognizedEmotionText = Text(detectedEmotion.emotion) + Text(" (") + Text(detectedEmotion.confidence, format: .percent) + Text(")")
            }
        }
    }
    
    private func runCreateML(on image: UIImage) async throws -> (emotion: String, confidence: Float)? {
        guard let cgImage = image.cgImage else {
            logger.error("Failed to create `ciImage`")
            return nil
        }
                
        let handler = ImageRequestHandler(cgImage)
        let results = try await handler.perform(request)
        
        guard let results = results as? [ClassificationObservation] else {
            logger.error("No results found")
            return nil
        }

        guard let bestResult = results.max(by: { a, b in a.confidence < b.confidence }) else {
            logger.error("No top result found")
          return nil
        }
        
        return (emotion: bestResult.identifier, confidence: bestResult.confidence)
    }
}
