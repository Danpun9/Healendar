import Foundation

class AlbumViewModel: ObservableObject {
  @Published var albums: [Album] = []
  @Published var selectedAlbum: Album? = nil
  @Published var selectedTag: String? = nil

  private let albumsFile = "albums.json"
  private let lastSelectedAlbumKey = ""

  init() {
    loadAlbums()
    loadLastSelectedAlbum()
  }

  func addAlbum(name: String) {
    let newAlbum = Album(id: UUID(), name: name, records: [])
    albums.append(newAlbum)
    saveAlbums()
    selectAlbum(newAlbum)
  }

  func selectAlbum(_ album: Album) {
    selectedAlbum = album
    UserDefaults.standard.set(album.id.uuidString, forKey: lastSelectedAlbumKey)
  }

  func moveAlbum(from source: IndexSet, to destination: Int) {
    albums.move(fromOffsets: source, toOffset: destination)
    saveAlbums()
  }

  func deleteAlbum(at offsets: IndexSet) {
    albums.remove(atOffsets: offsets)
    saveAlbums()

    if let selected = selectedAlbum, !albums.contains(where: { $0.id == selected.id }) {
      selectedAlbum = nil
      UserDefaults.standard.removeObject(forKey: lastSelectedAlbumKey)
    }
  }

  func addRecord(_ record: Record, originalData: Data, editedData: Data?) {
    guard let idx = albums.firstIndex(where: { $0.id == selectedAlbum?.id }) else { return }

    do {
      try originalData.write(to: record.originalImageURL)

      if let editedData = editedData, editedData != originalData {
        try editedData.write(to: record.editedImageURL!)
      }

      albums[idx].records.append(record)
      saveAlbums()
      selectedAlbum = albums[idx]
    } catch {
      print("이미지 저장 실패: \(error)")
    }
  }

  func deleteRecord(_ record: Record) {
    guard let albumIdx = albums.firstIndex(where: { $0.id == selectedAlbum?.id }) else { return }
    albums[albumIdx].records.removeAll { $0.id == record.id }

    try? FileManager.default.removeItem(at: record.originalImageURL)

    if let editedURL = record.editedImageURL {
      try? FileManager.default.removeItem(at: editedURL)
    }

    saveAlbums()
    selectedAlbum = albums[albumIdx]
  }

  func hasRecordForToday() -> Record? {
    guard let album = selectedAlbum else { return nil }
    let today = Calendar.current.startOfDay(for: Date())
    return album.records.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
  }

  func saveAlbums() {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(albums)
      let url = getDocumentsDirectory().appendingPathComponent(albumsFile)
      try data.write(to: url)
    } catch {
      print("앨범 저장 실패: \(error)")
    }
  }

  private func loadAlbums() {
    let url = getDocumentsDirectory().appendingPathComponent(albumsFile)
    print("앨범 파일 경로: \(url.path)")
    guard FileManager.default.fileExists(atPath: url.path) else {
      print("앨범 파일이 존재하지 않음")
      return
    }
    do {
      let data = try Data(contentsOf: url)
      albums = try JSONDecoder().decode([Album].self, from: data)
    } catch {
      print("앨범 불러오기 실패: \(error)")
    }
  }

  private func loadLastSelectedAlbum() {
    guard let idString = UserDefaults.standard.string(forKey: lastSelectedAlbumKey),
          let uuid = UUID(uuidString: idString),
          let album = albums.first(where: { $0.id == uuid }) else { return }
    selectedAlbum = album
  }

  private func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}
