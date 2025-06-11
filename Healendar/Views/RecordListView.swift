import SwiftUI

/// 선택된 앨범의 기록 목록을 표시하는 뷰
struct RecordListView: View {
  /// 앨범 데이터 및 상태 관리
  @ObservedObject var albumViewModel: AlbumViewModel

  var body: some View {
    List {
      // 선택된 앨범의 기록들을 리스트로 표시 (앨범 미선택 시 빈 배열 사용)
      ForEach(albumViewModel.selectedAlbum?.records ?? []) { record in
        // 각 기록을 가로 스택으로 표시
        HStack {
          // 편집 이미지가 있으면 편집본, 없으면 원본 이미지 표시
          if let image = record.loadEditedImage() ?? record.loadOriginalImage() {
            Image(uiImage: image)
              .resizable()
              .frame(width: 40, height: 40) // 썸네일 크기 고정
              .clipShape(RoundedRectangle(cornerRadius: 8)) // 둥근 모서리
          }

          // 텍스트 정보 (세로 스택)
          VStack(alignment: .leading) {
            Text(record.description) // 기록 설명
            Text(record.date, style: .date) // 날짜 (상대적 표시)
              .font(.caption) // 작은 폰트 크기
              .foregroundColor(.gray) // 회색 텍스트
          }
        }
      }
    }
    .navigationTitle("기록 목록") // 네비게이션 바 제목
  }
}
