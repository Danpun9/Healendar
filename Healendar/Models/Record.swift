import Foundation
import UIKit

struct Record: Identifiable, Codable, Equatable {
  let id: UUID
  var date: Date
  var originalImagePath: String
  var editedImagePath: String?
  var description: String
  var tags: [String]

  var originalImageURL: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(originalImagePath)
  }

  var editedImageURL: URL? {
    guard let path = editedImagePath else { return nil }
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(path)
  }

  func loadOriginalImage() -> UIImage? {
    UIImage(contentsOfFile: originalImageURL.path)
  }

  func loadEditedImage() -> UIImage? {
    if editedImageURL == nil { return nil }
    return UIImage(contentsOfFile: editedImageURL!.path)
  }
}
