import PhotosUI
import SwiftUI
import Vision

struct VisionDemoView: View {
    @State private var image = Image(systemName: "person.crop.square.badge.camera")
    @State private var isShowingImagePicker = false
    @State private var selectedImage: PhotosPickerItem?
    
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
            image
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.gray.opacity(0.6))
                .padding()
                .border(Color.secondary.opacity(0.4), width: 5)
                .cornerRadius(10)
        }
        .padding()
        .photosPicker(isPresented: $isShowingImagePicker, selection: $selectedImage, matching: .images)
        .onChange(of: selectedImage, initial: false) { _,newValue  in
            Task {
                guard let newValue,
                      let imageData = try? await newValue.loadTransferable(type: Data.self) else {
                    logger.error("Error loading image data from photo library")
                    return
                }
                        
                guard let uiImage = UIImage(data: imageData),
                      let transferredImage = try? await runVisionModel(on: uiImage) else {
                    logger.error("Error running Vision model")
                    return
                }
                self.image = Image(uiImage: transferredImage)
            }
        }
    }
    
    private func runVisionModel(on image: UIImage) async throws -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
                
        let request = DetectFaceLandmarksRequest()
        
        let results = try await request.perform(on: cgImage)
        
        let facesLandmarks: [FaceLandmark] = results.filter {
            $0.confidence > 0.5
        }.compactMap { detectedFace in
            guard let landmarks = detectedFace.landmarks else {
                return nil
            }
            return FaceLandmark(
                boundingBox: detectedFace.boundingBox,
                leftEye: landmarks.leftEye,
                rightEye: landmarks.rightEye)
        }
        
        return image.drawFacesLandmarks(facesLandmarks)
    }
}
