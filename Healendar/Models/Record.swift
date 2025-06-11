import Foundation
import UIKit

/// 사진 기록 정보를 관리하는 구조체 (Identifiable, Codable, Equatable 프로토콜 준수)
struct Record: Identifiable, Codable, Equatable {
  // MARK: - Properties
    
  /// 고유 식별자
  let id: UUID
  /// 기록 생성 날짜
  var date: Date
  /// 원본 이미지 파일 저장 경로
  var originalImagePath: String
  /// 편집본 이미지 파일 저장 경로
  var editedImagePath: String?
  /// 사용자 작성 설명 텍스트
  var description: String
  /// AI 생성 태그 목록
  var tags: [String]

  // MARK: - Computed Properties
    
  /// 원본 이미지의 전체 파일 URL
  var originalImageURL: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(originalImagePath)
  }
    
  /// 편집본 이미지의 전체 파일 URL (편집본 없을 경우 nil 반환)
  var editedImageURL: URL? {
    guard let path = editedImagePath else { return nil }
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(path)
  }

  // MARK: - Image Loading Methods
    
  /// 원본 이미지 로드 메서드
  /// - Returns: UIImage? (로드 실패 시 nil 반환)
  func loadOriginalImage() -> UIImage? {
    UIImage(contentsOfFile: originalImageURL.path)
  }
    
  /// 편집본 이미지 로드 메서드
  /// - Returns: UIImage? (편집본 없거나 로드 실패 시 nil 반환)
  func loadEditedImage() -> UIImage? {
    guard let editedURL = editedImageURL else { return nil }
    return UIImage(contentsOfFile: editedURL.path)
  }
}
