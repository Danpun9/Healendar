import SwiftUI

/// 현재 앱에서 활성화될 수 있는 시트 종류를 정의하는 열거형
enum ActiveSheet: Identifiable, Equatable {
  case editor(existing: Record?) // 기록 편집 시트, 기존 기록이 있을 수 있음
  case albumList // 앨범 리스트 시트
  case tagSearch // 태그 검색 시트
  case detail(record: Record) // 기록 상세 시트

  /// 각 케이스별 고유 ID 반환 (Identifiable 프로토콜 요구사항)
  var id: String {
    switch self {
    case .editor(let existing):
      return "editor-\(existing?.id.uuidString ?? "new")" // 기존 기록이 없으면 "new"
    case .albumList:
      return "albumList"
    case .tagSearch:
      return "tagSearch"
    case .detail(let record):
      return "detail-\(record.id.uuidString)"
    }
  }
}

/// 앱의 메인 뷰
struct MainView: View {
  // 앨범 데이터 및 상태 관리
  @StateObject var albumViewModel = AlbumViewModel()
  // 현재 활성화된 시트 상태
  @State private var activeSheet: ActiveSheet?
  // 선택된 기록 (달력에서 선택된 기록)
  @State private var selectedRecord: Record?
  // 오늘 기록이 이미 있을 때 경고창 표시 여부
  @State private var showAlert = false
  // 오늘 기록이 이미 있을 경우 기존 기록 저장
  @State private var existingRecord: Record?

  var body: some View {
    NavigationStack {
      // 하단 고정 버튼을 위한 ZStack
      ZStack(alignment: .bottom) {
        // 메인 콘텐츠 영역
        VStack {
          if let _ = albumViewModel.selectedAlbum {
            // 선택된 앨범이 있으면 캘린더 뷰 표시
            CalendarView(albumViewModel: albumViewModel, activeSheet: $activeSheet)
              .frame(maxHeight: .infinity)
              .ignoresSafeArea(edges: .bottom)
          } else {
            // 앨범이 선택되지 않았을 때 안내 텍스트 표시
            Text("앨범을 먼저 선택하세요.")
              .foregroundColor(.gray)
              .frame(maxHeight: .infinity)
          }
        }

        // 화면 하단에 고정된 "오늘 기록" 버튼
        Button {
          if let existing = albumViewModel.hasRecordForToday() {
            // 오늘 기록이 이미 있으면 기존 기록 저장 후 경고창 표시
            existingRecord = existing
            showAlert = true
          } else {
            // 오늘 기록이 없으면 기록 편집 시트 열기
            activeSheet = .editor(existing: nil)
          }
        } label: {
          HStack {
            Image(systemName: "plus.circle.fill")
            Text("오늘 기록")
          }
          .font(.headline)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(12)
          .padding(.horizontal)
          .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        // 앨범이 선택되지 않았으면 버튼 비활성화 및 투명도 조절
        .disabled(albumViewModel.selectedAlbum == nil)
        .opacity(albumViewModel.selectedAlbum == nil ? 0.5 : 1.0)
        .padding(.bottom, 20)
      }

      // 네비게이션 바 제목 설정 (앨범 이름 또는 기본값)
      .navigationTitle(albumViewModel.selectedAlbum?.name ?? "Healendar")
      .toolbar {
        // 왼쪽 네비게이션 바에 앨범 선택 버튼
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            activeSheet = .albumList
          } label: {
            HStack {
              Image(systemName: "list.bullet")
              Text("앨범 선택")
            }
          }
        }

        // 오른쪽 네비게이션 바에 태그 검색 버튼
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            activeSheet = .tagSearch
          } label: {
            Image(systemName: "magnifyingglass")
          }
        }
      }

      // 활성화된 시트에 따라 다른 뷰를 시트로 표시
      .sheet(item: $activeSheet) { item in
        switch item {
        case .editor(let existing):
          RecordEditorView(albumViewModel: albumViewModel, existingRecord: existing)
        case .albumList:
          AlbumListView(albumViewModel: albumViewModel)
        case .tagSearch:
          TagSearchView(albumViewModel: albumViewModel)
        case .detail(let record):
          RecordDetailView(record: record)
            .environmentObject(albumViewModel)
        }
      }

      // 오늘 기록이 이미 있을 때 경고창 표시
      .alert("기존 기록 교체", isPresented: $showAlert) {
        Button("취소", role: .cancel) {}
        Button("새로 작성") {
          activeSheet = .editor(existing: existingRecord)
        }
      } message: {
        Text("오늘 날짜에 이미 기록이 있습니다. 기존 기록을 새 기록으로 교체하시겠습니까?")
      }
    }
  }
}
