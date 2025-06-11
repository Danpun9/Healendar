import UIKit

extension UIImage {
  /// 이미지의 가로 세로 비율을 유지하며 지정된 크기로 리사이즈합니다.
  /// - Parameter size: 목표 크기 (비율 유지됨)
  /// - Returns: 리사이즈된 UIImage 객체 (실패 시 nil 반환)
  func resized(to size: CGSize) -> UIImage? {
    let aspectRatio = self.size.width / self.size.height
    let newSize: CGSize

    // 가로 모드 이미지 처리 (가로 > 세로)
    if aspectRatio > 1 {
      newSize = CGSize(width: size.width, height: size.width / aspectRatio)
    }
    // 세로 모드 이미지 처리 (세로 ≥ 가로)
    else {
      newSize = CGSize(width: size.height * aspectRatio, height: size.height)
    }

    // 고품질 렌더링을 위한 이미지 렌더러 사용
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
      self.draw(in: CGRect(origin: .zero, size: newSize))
    }
  }
  
  /// 정확한 지정 크기로 이미지를 강제 리사이즈합니다 (비율 무시).
  /// - Parameter size: 목표 크기 (비율 무시)
  /// - Returns: 리사이즈된 UIImage 객체 (실패 시 nil 반환)
  func resizedTo(size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    defer { UIGraphicsEndImageContext() } // 컨텍스트 정리 보장
    draw(in: CGRect(origin: .zero, size: size))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
      
  /// Core ML 모델 입력용으로 이미지를 CVPixelBuffer로 변환합니다.
  /// - Returns: 32BGRA 포맷의 CVPixelBuffer (변환 실패 시 nil)
  /// - Important: 머신러닝 모델 입력에 적합한 224x224 크기로 리사이즈 필요
  func pixelBuffer() -> CVPixelBuffer? {
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer: CVPixelBuffer?
        
    // 버퍼 생성 (너비, 높이, 픽셀 포맷 지정)
    let status = CVPixelBufferCreate(
      kCFAllocatorDefault,
      Int(size.width),
      Int(size.height),
      kCVPixelFormatType_32BGRA,
      attrs,
      &pixelBuffer
    )
    guard status == kCVReturnSuccess else { return nil }
          
    // 메모리 잠금 및 자동 해제 설정
    CVPixelBufferLockBaseAddress(pixelBuffer!, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer!, .readOnly) }
          
    // 그래픽 컨텍스트 생성 및 이미지 드로잉
    let context = CGContext(
      data: CVPixelBufferGetBaseAddress(pixelBuffer!),
      width: Int(size.width),
      height: Int(size.height),
      bitsPerComponent: 8, // 채널당 8비트
      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
      space: CGColorSpaceCreateDeviceRGB(), // RGB 컬러 스페이스
      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue // 알파 채널 무시
    )
          
    context?.draw(
      cgImage!,
      in: CGRect(x: 0, y: 0, width: size.width, height: size.height)
    )
    return pixelBuffer
  }
}
