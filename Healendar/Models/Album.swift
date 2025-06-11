import Foundation
import UIKit

struct Album: Identifiable, Codable {
  let id: UUID
  var name: String
  var records: [Record]
}
