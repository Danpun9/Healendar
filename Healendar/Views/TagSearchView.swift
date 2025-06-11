import SwiftUI

/// 태그 검색 및 빈도수 확인을 위한 뷰
struct TagSearchView: View {
  // MARK: - Properties

  @ObservedObject var albumViewModel: AlbumViewModel // 앨범 데이터 관리
  @Environment(\.dismiss) var dismiss // 뷰 닫기 액션

  /// 선택된 앨범의 태그 사용 빈도수 계산
  var tagFrequency: [String: Int] {
    var frequencyDict = [String: Int]()
    guard let album = albumViewModel.selectedAlbum else { return frequencyDict }

    // 모든 기록의 태그를 순회하며 빈도수 카운트
    for record in album.records {
      for tag in record.tags {
        frequencyDict[tag] = (frequencyDict[tag] ?? 0) + 1
      }
    }
    return frequencyDict
  }

  // MARK: - Body

  var body: some View {
    NavigationStack {
      List {
        // 빈도수 기준 내림차순 정렬된 태그 목록
        ForEach(tagFrequency.sorted(by: { $0.value > $1.value }), id: \.key) { tag, count in
          // 개별 태그 버튼
          Button {
            albumViewModel.selectedTag = tag // 태그 선택 상태 업데이트
          } label: {
            HStack {
              Text("#\(tag)") // 태그 이름
              Spacer()
              Text("\(count)회") // 사용 횟수
                .foregroundColor(.gray)
            }
          }
        }
      }
      .navigationTitle("태그 검색") // 네비게이션 제목
      .toolbar {
        // 닫기 버튼 - 우측 상단 배치
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("닫기") { dismiss() }
        }
      }
      // 선택된 태그에 대한 기록 목록 시트 표시
      .sheet(item: $albumViewModel.selectedTag) { tag in
        TaggedRecordListView(
          albumViewModel: albumViewModel,
          tag: tag
        )
      }
    }
  }
}
