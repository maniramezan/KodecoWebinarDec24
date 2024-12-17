import UIKit
import Vision

extension UIImage {
    func drawFacesLandmarks(_ facesLandmarks: [FaceLandmark]) -> UIImage? {
        guard let cgImage else {
            logger.error("Failed to create `cgImage`")
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: size, format: imageRendererFormat)
    
        func drawEye(_ eyeRegion: FaceObservation.Landmarks2D.Region, context: UIGraphicsImageRendererContext) {
            context.cgContext.setLineWidth(2.0)
            context.cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            context.cgContext.setFillColor(UIColor.systemMint.cgColor)
            
            let normalizedEyePoints = eyeRegion.pointsInImageCoordinates(size)
            
            let eyePath = UIBezierPath()
            eyePath.move(to: normalizedEyePoints[0])
            normalizedEyePoints.dropFirst().forEach { eyePath.addLine(to: $0) }
            eyePath.close()
            eyePath.fill()
        }
        
        let resultImage = renderer.image { context in
            context.cgContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
            context.cgContext.setFillColor(UIColor.systemPink.cgColor)
            
            facesLandmarks.forEach { faceLandmarks in
                let faceInImageCoorniates = faceLandmarks.boundingBox.toImageCoordinates(size)
                let facePath = UIBezierPath(ovalIn: faceInImageCoorniates)
                facePath.fill()
                
                drawEye(faceLandmarks.leftEye, context: context)
                drawEye(faceLandmarks.rightEye, context: context)
            }
        }
        
        guard let resulCGImage = resultImage.cgImage else {
            logger.error("Failed to create `cgImage`")
            return nil
        }

        return UIImage(
            cgImage: resulCGImage,
            scale: scale,
            orientation: adjustOrientation())
    }
    
    /// Adjusts the orientation of the image based on its current orientation.
    ///
    /// This method is private and only accessible within the extension to ensure that it is only used internally.
    ///
    /// - Returns: The adjusted orientation that is the mirrored counterpart of the image's current orientation.
    private func adjustOrientation() -> UIImage.Orientation {
        switch imageOrientation {
        case .up:
            return .downMirrored
        case .upMirrored:
            return .up
        case .down:
            return .upMirrored
        case .downMirrored:
            return .down
        case .left:
            return .rightMirrored
        case .rightMirrored:
            return .left
        case .right:
            return .leftMirrored
        case .leftMirrored:
            return .right
        @unknown default:
            return self.imageOrientation
        }
    }
}
