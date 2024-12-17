import Vision

struct FaceLandmark: CustomDebugStringConvertible, CustomStringConvertible {
    let boundingBox: NormalizedRect
    let leftEye: FaceObservation.Landmarks2D.Region
    let rightEye: FaceObservation.Landmarks2D.Region
    
    var description: String {
        debugDescription
    }
    
    var debugDescription: String {
        "FaceLandmark: boundingBox: \(boundingBox), leftEye: \(leftEye), rightEye: \(rightEye)"
    }
}
