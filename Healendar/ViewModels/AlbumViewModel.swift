import Foundation
import SwiftUI

/// 앨범 및 기록 데이터를 관리하는 뷰 모델 (SwiftUI ObservableObject)
class AlbumViewModel: ObservableObject {
  // MARK: - Published Properties

  @Published var albums: [Album] = [] // 모든 앨범 목록
  @Published var selectedAlbum: Album? = nil // 현재 선택된 앨범
  @Published var selectedTag: String? = nil // 현재 선택된 태그 (검색용)
  @Published var selectedDate: Date?
  @Published var activeSheet: ActiveSheet?
  @Published var isPresentingFullScreenImage = false
  @Published var fullScreenImage: UIImage?

  // MARK: - Private Properties

  private let albumsFile = "albums.json" // 앨범 데이터 저장 파일명
  private let lastSelectedAlbumKey = "lastSelectedAlbum" // 마지막 선택 앨범 저장 키
    
  // MARK: - Initialization

  init() {
    loadAlbums() // 저장된 앨범 데이터 로드
    loadLastSelectedAlbum() // 마지막으로 선택된 앨범 복원
  }
    
  // MARK: - Album Management

  /// 새 앨범 생성 및 저장
  func addAlbum(name: String) {
    let newAlbum = Album(id: UUID(), name: name, records: [])
    albums.append(newAlbum)
    saveAlbums() // 변경사항 저장
    selectAlbum(newAlbum) // 자동 선택
  }
    
  /// 앨범 선택 및 저장
  func selectAlbum(_ album: Album) {
    selectedAlbum = album
    UserDefaults.standard.set(album.id.uuidString, forKey: lastSelectedAlbumKey)
  }
    
  /// 앨범 순서 변경
  func moveAlbum(from source: IndexSet, to destination: Int) {
    albums.move(fromOffsets: source, toOffset: destination)
    saveAlbums()
  }
    
  /// 앨범 삭제
  func deleteAlbum(at offsets: IndexSet) {
    albums.remove(atOffsets: offsets)
    saveAlbums()
        
    // 삭제된 앨범이 선택된 상태였다면 초기화
    if let selected = selectedAlbum, !albums.contains(where: { $0.id == selected.id }) {
      selectedAlbum = nil
      UserDefaults.standard.removeObject(forKey: lastSelectedAlbumKey)
    }
  }
    
  // MARK: - Record Management

  /// 새로운 기록 추가 (이미지 파일 저장 포함)
  func addRecord(_ record: Record, originalData: Data, editedData: Data?) {
    guard let idx = albums.firstIndex(where: { $0.id == selectedAlbum?.id }) else { return }
        
    do {
      // 원본 이미지 저장
      try originalData.write(to: record.originalImageURL)
            
      // 편집본이 있고 원본과 다를 경우 저장
      if let editedData = editedData, editedData != originalData {
        try editedData.write(to: record.editedImageURL!)
      }
            
      albums[idx].records.append(record)
      saveAlbums()
      selectedAlbum = albums[idx] // 선택 앨범 갱신
    } catch {
      print("이미지 저장 실패: \(error)")
    }
  }
    
  /// 기록 삭제 (이미지 파일 함께 삭제)
  func deleteRecord(_ record: Record) {
    guard let albumIdx = albums.firstIndex(where: { $0.id == selectedAlbum?.id }) else { return }
    albums[albumIdx].records.removeAll { $0.id == record.id }
        
    // 이미지 파일 삭제
    try? FileManager.default.removeItem(at: record.originalImageURL)
    if let editedURL = record.editedImageURL {
      try? FileManager.default.removeItem(at: editedURL)
    }
        
    saveAlbums()
    selectedAlbum = albums[albumIdx] // 선택 앨범 갱신
  }
    
  /// 오늘 날짜의 기록 존재 여부 확인
  func hasRecordForToday() -> Record? {
    guard let album = selectedAlbum else { return nil }
    let today = Calendar.current.startOfDay(for: Date())
    return album.records.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
  }
    
  // MARK: - Data Persistence

  /// 앨범 데이터 저장 (JSON)
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
    
  /// 앨범 데이터 로드 (JSON)
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
    
  /// 마지막 선택 앨범 로드 (UserDefaults)
  private func loadLastSelectedAlbum() {
    guard let idString = UserDefaults.standard.string(forKey: lastSelectedAlbumKey),
          let uuid = UUID(uuidString: idString),
          let album = albums.first(where: { $0.id == uuid }) else { return }
    selectedAlbum = album
  }
    
  // MARK: - File Management

  /// 문서 디렉토리 경로 반환
  private func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}
