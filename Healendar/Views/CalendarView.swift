import FSCalendar
import SwiftUI

/// FSCalendar를 SwiftUI에서 사용하기 위한 래퍼 뷰
struct CalendarView: UIViewRepresentable {
  // 앨범 데이터 및 상태 관리
  @ObservedObject var albumViewModel: AlbumViewModel
  // 현재 활성화된 시트 상태 (MainView와 연동)
  @Binding var activeSheet: ActiveSheet?
  @Binding var selectedDate: Date?
  @Binding var showDateAlert: Bool

  /// Coordinator 생성: FSCalendar의 델리게이트 및 데이터소스 역할
  func makeCoordinator() -> Coordinator {
    Coordinator(self, albumViewModel: albumViewModel)
  }

  /// FSCalendar 인스턴스 생성 및 초기화
  func makeUIView(context: Context) -> FSCalendar {
    let calendar = FSCalendar()
    calendar.delegate = context.coordinator
    calendar.dataSource = context.coordinator
    // 커스텀 셀 등록
    calendar.register(ImageCalendarCell.self, forCellReuseIdentifier: "cell")

    // 캘린더 스타일 설정
    calendar.appearance.selectionColor = .clear // 선택된 날짜 배경색 제거
    calendar.appearance.todayColor = .clear // 오늘 날짜 배경색 제거
    calendar.appearance.borderRadius = 0.4 // 셀 모서리 둥글기

    // 다크 모드 대응: 텍스트 색상 시스템 컬러로 지정
    calendar.appearance.titleDefaultColor = UIColor.label
    calendar.appearance.titleSelectionColor = UIColor.label
    calendar.appearance.titleTodayColor = UIColor.label

    return calendar
  }

  /// 뷰 업데이트 시 데이터 리로드
  func updateUIView(_ uiView: FSCalendar, context: Context) {
    uiView.reloadData()
  }

  /// FSCalendar의 델리게이트 및 데이터소스
  class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
    var parent: CalendarView
    var albumViewModel: AlbumViewModel

    init(_ parent: CalendarView, albumViewModel: AlbumViewModel) {
      self.parent = parent
      self.albumViewModel = albumViewModel
    }

    /// 각 날짜 셀에 이미지 표시
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
      let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! ImageCalendarCell
      // 선택된 앨범의 기록 중 해당 날짜에 해당하는 기록이 있으면 이미지 표시
      if let records = albumViewModel.selectedAlbum?.records,
         let record = records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }),
         // 편집 이미지가 있으면 편집본, 없으면 원본 이미지 사용
         let image = if record.loadEditedImage() != nil { record.loadEditedImage()! } else { record.loadOriginalImage() } {
        cell.backImageView.image = image.resized(to: cell.backImageView.bounds.size)
      } else {
        cell.backImageView.image = nil
      }
      return cell
    }

    /// 날짜 선택 시 해당 기록의 상세 시트 표시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
      if let record = albumViewModel.selectedAlbum?.records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
        parent.activeSheet = .detail(record: record)
      } else {
        // 기록이 없으면 선택된 날짜 저장 및 알림 표시
        parent.selectedDate = date
        parent.showDateAlert = true
      }
    }
  }
}
