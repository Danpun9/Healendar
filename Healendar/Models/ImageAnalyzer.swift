import CoreML
import UIKit

class ImageAnalyzer {
  static let shared = ImageAnalyzer()
  private let model: MobileNetV2
    
  init() {
    do {
      self.model = try MobileNetV2(configuration: .init())
    } catch {
      fatalError("모델 초기화 실패: \(error)")
    }
  }
    
  func generateTags(image: UIImage) -> [String] {
    guard let resizedImage = image.resizedTo(size: CGSize(width: 224, height: 224)),
          let buffer = resizedImage.pixelBuffer()
    else {
      return []
    }
        
    do {
      let output = try model.prediction(image: buffer)
      return output.classLabelProbs
        .sorted { $0.value > $1.value }
        .prefix(3)
        .map { $0.key.replacingOccurrences(of: ",", with: "") }
    } catch {
      print("AI 분석 오류: \(error)")
      return []
    }
  }
}
