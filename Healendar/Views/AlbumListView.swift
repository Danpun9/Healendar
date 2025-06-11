import SwiftUI

/// 앨범 목록을 보여주고, 선택/삭제/순서 변경/추가 기능을 제공하는 뷰
struct AlbumListView: View {
  // 앨범 데이터 및 상태 관리
  @ObservedObject var albumViewModel: AlbumViewModel
  // 현재 뷰를 닫기 위한 환경 값
  @Environment(\.dismiss) var dismiss
  // 새 앨범 생성 알림창 표시 여부
  @State private var showNewAlbumAlert = false
  // 새 앨범 이름 입력 필드
  @State private var newAlbumName: String = ""
  // 리스트 편집 모드 상태
  @State private var editMode: EditMode = .inactive

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // 앨범 리스트
        List {
          ForEach(albumViewModel.albums) { album in
            // 각 앨범을 버튼으로 표시
            Button {
              // 앨범 선택 시 앨범을 선택하고 현재 뷰를 닫음
              albumViewModel.selectAlbum(album)
              dismiss()
            } label: {
              HStack {
                Text(album.name)
                // 현재 선택된 앨범에는 체크마크 표시
                if albumViewModel.selectedAlbum?.id == album.id {
                  Spacer()
                  Image(systemName: "checkmark")
                }
              }
            }
            // 오른쪽으로 스와이프: 삭제 액션
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button(role: .destructive) {
                // 해당 앨범의 인덱스를 찾아 삭제
                if let idx = albumViewModel.albums.firstIndex(where: { $0.id == album.id }) {
                  albumViewModel.deleteAlbum(at: IndexSet(integer: idx))
                }
              } label: {
                Label("삭제", systemImage: "trash")
              }
            }
            // 왼쪽으로 스와이프: 순서 변경 모드 진입
            .swipeActions(edge: .leading) {
              Button {
                // 애니메이션과 함께 편집 모드 활성화
                withAnimation { editMode = .active }
              } label: {
                Label("순서 변경", systemImage: "arrow.up.arrow.down")
              }
              .tint(.blue)
            }
          }
          // 드래그 액션: 앨범 순서 변경
          .onMove(perform: albumViewModel.moveAlbum)
        }
        // 편집 모드 연결
        .environment(\.editMode, $editMode)

        // 새 앨범 만들기 버튼
        Button(action: { showNewAlbumAlert = true }) {
          HStack {
            Image(systemName: "plus.circle")
            Text("새 앨범 만들기")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
          .padding(.bottom, 16)
        }
      }
      .navigationTitle("앨범 선택")
      // 새 앨범 생성 알림창
      .alert("새 앨범 이름", isPresented: $showNewAlbumAlert) {
        TextField("앨범 이름", text: $newAlbumName)
        Button("취소", role: .cancel) { newAlbumName = "" }
        Button("추가") {
          // 앨범 이름 공백 제거 후 추가
          let trimmed = newAlbumName.trimmingCharacters(in: .whitespaces)
          if !trimmed.isEmpty {
            albumViewModel.addAlbum(name: trimmed)
          }
          newAlbumName = ""
        }
      } message: {
        Text("앨범의 이름을 입력하세요.")
      }
    }
  }
}
