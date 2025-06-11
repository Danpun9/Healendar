import SwiftUI

struct TaggedRecordListView: View {
  @ObservedObject var albumViewModel: AlbumViewModel
  let tag: String

  var taggedRecords: [Record] {
    guard let album = albumViewModel.selectedAlbum else { return [] }
    return album.records.filter { $0.tags.contains(tag) }
  }

  var body: some View {
    NavigationStack {
      List(taggedRecords) { record in
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
      .navigationTitle("#\(tag)")
    }
  }
}
