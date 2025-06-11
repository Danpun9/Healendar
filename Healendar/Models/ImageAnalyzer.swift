import CoreML
import UIKit

/// 이미지 분석
class ImageAnalyzer {
  /// 전역에서 접근 가능한 공유 인스턴스
  static let shared = ImageAnalyzer()

  // MARK: - CoreML Properties

  /// MobileNetV2 머신러닝 모델 인스턴스
  private let model: MobileNetV2

  // MARK: - Initialization

  /// 모델 초기화 (에러 발생 시 앱 크래시 방지를 위해 fatalError 처리)
  init() {
    do {
      self.model = try MobileNetV2(configuration: .init())
    } catch {
      fatalError("모델 초기화 실패: \(error)")
    }
  }

  // MARK: - Image Processing

  /// 이미지 분석 후 상위 3개 태그 반환
  /// - Parameter image: 분석할 원본 UIImage
  /// - Returns: 생성된 태그 문자열 배열 (최대 3개)
  func generateTags(image: UIImage) -> [String] {
    // 1. 이미지 전처리: 모델 입력 크기(224x224)로 리사이징
    guard let resizedImage = image.resizedTo(size: CGSize(width: 224, height: 224)),
          // 2. CoreML 입력 형식으로 변환 (CVPixelBuffer)
          let buffer = resizedImage.pixelBuffer()
    else {
      return []
    }

    // 3. 모델 예측 수행
    do {
      let output = try model.prediction(image: buffer)

      // 4. 결과 후처리
      return output.classLabelProbs
        .sorted { $0.value > $1.value } // 확률 기준 내림차순 정렬
        .prefix(3) // 상위 3개 선택
        .map { $0.key.replacingOccurrences(of: ",", with: "") } // 특수문자 제거
    } catch {
      print("AI 분석 오류: \(error)")
      return []
    }
  }
}
