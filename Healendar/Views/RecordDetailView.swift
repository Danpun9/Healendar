import SwiftUI

/// 사진 기록의 상세 정보를 표시하고 관리하는 뷰
struct RecordDetailView: View {
  // MARK: - Properties

  let record: Record // 표시할 기록 객체
  @EnvironmentObject var albumViewModel: AlbumViewModel // 앨범 데이터 관리
  @Environment(\.dismiss) var dismiss // 뷰 닫기 액션
  @State private var showActionAlert = false // 액션 메뉴 표시 상태
    
  // MARK: - Body

  var body: some View {
    VStack(spacing: 20) {
      // 이미지 표시 섹션
      imageDisplaySection
            
      // 태그 목록 섹션
      tagListSection
            
      // 설명 및 날짜 섹션
      descriptionSection
            
      Spacer()
    }
    .navigationTitle("기록 상세")
    .overlay(alignment: .bottomTrailing) { actionButton } // 오른쪽 하단 액션 버튼
    .alert("기록 관리", isPresented: $showActionAlert) { actionAlert } // 삭제 알림창
    .sheet(item: $albumViewModel.selectedTag) { tag in // 태그 검색 시트
      TaggedRecordListView(albumViewModel: albumViewModel, tag: tag)
    }
    .fullScreenCover(isPresented: $albumViewModel.isPresentingFullScreenImage) { // 크게 보기
      if let image = albumViewModel.fullScreenImage {
        FullScreenImageView(image: image)
      }
    }
  }
    
  // MARK: - Subviews
    
  /// 이미지 표시 영역 (편집본 우선)
  private var imageDisplaySection: some View {
    Group {
      if let image = record.loadEditedImage() ?? record.loadOriginalImage() {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(height: 300)
          .onTapGesture {
            albumViewModel.isPresentingFullScreenImage = true
            albumViewModel.fullScreenImage = image
          }
      } else {
        Text("사진 불러오기 실패")
          .frame(height: 300)
      }
    }
  }

  /// 태그 목록 (가로 스크롤)
  private var tagListSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(record.tags, id: \.self) { tag in
          Button {
            albumViewModel.selectedTag = tag // 태그 선택 상태 업데이트
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
  }
    
  /// 설명 및 날짜 정보
  private var descriptionSection: some View {
    VStack(spacing: 10) {
      Text(record.description)
        .font(.body)
      Text(record.date, style: .date)
        .font(.caption)
        .foregroundColor(.gray)
    }
    .padding(.horizontal)
  }
    
  /// 오른쪽 하단 액션 버튼 (···)
  private var actionButton: some View {
    Button {
      showActionAlert = true
    } label: {
      Image(systemName: "ellipsis.circle.fill")
        .font(.system(size: 32))
        .foregroundColor(.blue)
    }
    .padding(20)
  }
    
  /// 삭제 확인 알림창
  private var actionAlert: some View {
    Group {
      Button("삭제", role: .destructive) {
        albumViewModel.deleteRecord(record)
        dismiss() // 상세 뷰 자동 닫힘
      }
      Button("취소", role: .cancel) {}
    }
  }
}
