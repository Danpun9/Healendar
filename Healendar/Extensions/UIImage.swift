import UIKit

extension UIImage {
  func resized(to size: CGSize) -> UIImage? {
    let aspectRatio = self.size.width / self.size.height
    let newSize: CGSize

    if aspectRatio > 1 {
      newSize = CGSize(width: size.width, height: size.width / aspectRatio)
    } else {
      newSize = CGSize(width: size.height * aspectRatio, height: size.height)
    }

    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
      self.draw(in: CGRect(origin: .zero, size: newSize))
    }
  }
  
  func resizedTo(size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: size))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
      
  func pixelBuffer() -> CVPixelBuffer? {
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(
      kCFAllocatorDefault, Int(size.width), Int(size.height),
      kCVPixelFormatType_32BGRA, attrs, &pixelBuffer
    )
    guard status == kCVReturnSuccess else { return nil }
          
    CVPixelBufferLockBaseAddress(pixelBuffer!, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer!, .readOnly) }
          
    let context = CGContext(
      data: CVPixelBufferGetBaseAddress(pixelBuffer!),
      width: Int(size.width),
      height: Int(size.height),
      bitsPerComponent: 8,
      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
    )
          
    context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    return pixelBuffer
  }
}
