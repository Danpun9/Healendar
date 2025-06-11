import SwiftUI

struct RecordListView: View {
  @ObservedObject var albumViewModel: AlbumViewModel

  var body: some View {
    List {
      ForEach(albumViewModel.selectedAlbum?.records ?? []) { record in
        HStack {
          if let image = record.loadEditedImage() ?? record.loadOriginalImage() {
            Image(uiImage: image)
              .resizable()
              .frame(width: 40, height: 40)
              .clipShape(RoundedRectangle(cornerRadius: 8))
          }
          VStack(alignment: .leading) {
            Text(record.description)
            Text(record.date, style: .date)
              .font(.caption)
              .foregroundColor(.gray)
          }
        }
      }
    }
    .navigationTitle("기록 목록")
  }
}
