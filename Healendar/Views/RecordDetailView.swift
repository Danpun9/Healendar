import SwiftUI

struct RecordDetailView: View {
  let record: Record
  @EnvironmentObject var albumViewModel: AlbumViewModel

  var body: some View {
    VStack(spacing: 20) {
      if let image = record.loadEditedImage() ?? record.loadOriginalImage() {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(height: 300)
      } else {
        Text("사진 불러오기 실패")
          .frame(height: 300)
      }

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(record.tags, id: \.self) { tag in
            Button {
              albumViewModel.selectedTag = tag
            } label: {
              Text("#\(tag)")
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                .font(.caption)
            }
          }
        }
        .padding(.horizontal)
      }
      .frame(height: 40)

      VStack(spacing: 10) {
        Text(record.description)
          .font(.body)

        Text(record.date, style: .date)
          .font(.caption)
          .foregroundColor(.gray)
      }
      .padding(.horizontal)

      Spacer()
    }
    .navigationTitle("기록 상세")
    .sheet(item: $albumViewModel.selectedTag) { tag in
      TaggedRecordListView(
        albumViewModel: albumViewModel,
        tag: tag
      )
    }
  }
}
