import SwiftUI

struct AlbumListView: View {
  @ObservedObject var albumViewModel: AlbumViewModel
  @Environment(\.dismiss) var dismiss
  @State private var showNewAlbumAlert = false
  @State private var newAlbumName: String = ""
  @State private var editMode: EditMode = .inactive

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        List {
          ForEach(albumViewModel.albums) { album in
            Button {
              albumViewModel.selectAlbum(album)
              dismiss()
            } label: {
              HStack {
                Text(album.name)
                if albumViewModel.selectedAlbum?.id == album.id {
                  Spacer()
                  Image(systemName: "checkmark")
                }
              }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button(role: .destructive) {
                if let idx = albumViewModel.albums.firstIndex(where: { $0.id == album.id }) {
                  albumViewModel.deleteAlbum(at: IndexSet(integer: idx))
                }
              } label: {
                Label("삭제", systemImage: "trash")
              }
            }
            .swipeActions(edge: .leading) {
              Button {
                withAnimation { editMode = .active }
              } label: {
                Label("순서 변경", systemImage: "arrow.up.arrow.down")
              }
              .tint(.blue)
            }
          }
          .onMove(perform: albumViewModel.moveAlbum)
        }
        .environment(\.editMode, $editMode)

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
      .alert("새 앨범 이름", isPresented: $showNewAlbumAlert) {
        TextField("앨범 이름", text: $newAlbumName)
        Button("취소", role: .cancel) { newAlbumName = "" }
        Button("추가") {
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
