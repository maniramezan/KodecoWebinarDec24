import PhotosUI
import SwiftUI

struct VisionDemoView: View {
    @State private var image = Image(systemName: "person.crop.square.badge.camera")
    @State private var isShowingImagePicker = false
    @State private var selectedImage: PhotosPickerItem?
    
    var body: some View {
        Menu {
            Button {
                isShowingImagePicker.toggle()
            } label: {
                Label("Photo album", systemImage: "photo")
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
        .onChange(of: selectedImage, initial: false) { _, newValue in
            Task {
                guard let newValue,
                      let imageData = try? await newValue.loadTransferable(type: Data.self) else {
                    logger.error("Error loading image data from photo library")
                    return
                }
                
                guard let image = UIImage(data: imageData) else {
                    logger.error("Error running Vision model")
                    return
                }
                self.image = Image(uiImage: image)
            }
        }
    }
}
