import SwiftUI

struct TagSearchView: View {
  @ObservedObject var albumViewModel: AlbumViewModel
  @Environment(\.dismiss) var dismiss

  var tagFrequency: [String: Int] {
    var dict = [String: Int]()
    guard let album = albumViewModel.selectedAlbum else { return dict }
    for record in album.records {
      for tag in record.tags {
        dict[tag] = (dict[tag] ?? 0) + 1
      }
    }
    return dict
  }

  var body: some View {
    NavigationStack {
      List {
        ForEach(tagFrequency.sorted(by: { $0.value > $1.value }), id: \.key) { tag, count in
          Button {
            albumViewModel.selectedTag = tag
          } label: {
            HStack {
              Text("#\(tag)")
              Spacer()
              Text("\(count)회")
                .foregroundColor(.gray)
            }
          }
        }
      }
      .navigationTitle("태그 검색")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("닫기") { dismiss() }
        }
      }
      .sheet(item: $albumViewModel.selectedTag) { tag in
        TaggedRecordListView(
          albumViewModel: albumViewModel,
          tag: tag
        )
      }
    }
  }
}
