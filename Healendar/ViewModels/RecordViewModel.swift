import Foundation

class RecordViewModel: ObservableObject {
  @Published var records: [Record] = []
  private let recordsFile = "records.json"

  init() {
    loadRecords()
  }

  func saveRecord(_ record: Record, originalData: Data, editedData: Data?) {
    do {
      try originalData.write(to: record.originalImageURL)
    } catch {
      print("원본 이미지 저장 실패: \(error)")
    }

    if let editedData = editedData {
      do {
        try editedData.write(to: record.editedImageURL!)
      } catch {
        print("편집본 이미지 저장 실패: \(error)")
      }
    }

    records.append(record)
    saveRecords()
  }

  func deleteRecord(_ record: Record) {
    records.removeAll { $0.id == record.id }
    try? FileManager.default.removeItem(at: record.originalImageURL)

    if let editedURL = record.editedImageURL {
      try? FileManager.default.removeItem(at: editedURL)
    }
    saveRecords()
  }

  private func saveRecords() {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(records)
      let url = getDocumentsDirectory().appendingPathComponent(recordsFile)
      try data.write(to: url)
    } catch {
      print("기록 저장 실패: \(error)")
    }
  }

  func loadRecords() {
    let url = getDocumentsDirectory().appendingPathComponent(recordsFile)
    guard FileManager.default.fileExists(atPath: url.path) else { return }
    do {
      let data = try Data(contentsOf: url)
      records = try JSONDecoder().decode([Record].self, from: data)
    } catch {
      print("기록 불러오기 실패: \(error)")
    }
  }

  func hasRecordForToday() -> Record? {
    let today = Calendar.current.startOfDay(for: Date())
    return records.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
  }

  private func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}
