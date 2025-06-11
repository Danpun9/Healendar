import SwiftUI

/// 특정 태그가 포함된 기록(Record) 목록을 보여주는 뷰
struct TaggedRecordListView: View {
  // 앨범 데이터 및 상태 관리 (ObservableObject)
  @ObservedObject var albumViewModel: AlbumViewModel
  // 표시할 태그 문자열
  let tag: String

  /// 선택된 앨범에서 해당 태그가 포함된 기록만 필터링하여 반환
  var taggedRecords: [Record] {
    guard let album = albumViewModel.selectedAlbum else { return [] }
    return album.records.filter { $0.tags.contains(tag) }
  }

  var body: some View {
    NavigationStack {
      // 필터링된 기록 목록을 리스트로 표시
      List(taggedRecords) { record in
        HStack {
          // 편집 이미지가 있으면 편집본, 없으면 원본 이미지 표시
          if let image = record.loadEditedImage() ?? record.loadOriginalImage() {
            Image(uiImage: image)
              .resizable()
              .frame(width: 40, height: 40) // 썸네일 크기 고정
              .clipShape(RoundedRectangle(cornerRadius: 8)) // 둥근 모서리
          }
          // 기록 설명과 날짜 표시 (세로 스택)
          VStack(alignment: .leading) {
            Text(record.description) // 기록 설명
            Text(record.date, style: .date) // 날짜 (상대적 표시)
              .font(.caption) // 작은 폰트 크기
              .foregroundColor(.gray) // 회색 텍스트
          }
        }
      }
      // 네비게이션 바 제목 (태그 앞에 # 추가)
      .navigationTitle("#\(tag)")
    }
  }
}
