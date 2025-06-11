import Foundation
import UIKit

/// 앨범 정보를 나타내는 구조체
struct Album: Identifiable, Codable {
  let id: UUID // 앨범 고유 식별자
  var name: String // 앨범 이름
  var records: [Record] // 앨범에 포함된 기록(Record) 배열
}
