import FSCalendar
import SwiftUI

struct CalendarView: UIViewRepresentable {
  @ObservedObject var albumViewModel: AlbumViewModel
  @Binding var activeSheet: ActiveSheet?

  func makeCoordinator() -> Coordinator {
    Coordinator(self, albumViewModel: albumViewModel)
  }

  func makeUIView(context: Context) -> FSCalendar {
    let calendar = FSCalendar()
    calendar.delegate = context.coordinator
    calendar.dataSource = context.coordinator
    calendar.register(ImageCalendarCell.self, forCellReuseIdentifier: "cell")

    calendar.appearance.selectionColor = .clear
    calendar.appearance.todayColor = .clear
    calendar.appearance.borderRadius = 0.4

    calendar.appearance.titleDefaultColor = UIColor.label
    calendar.appearance.titleSelectionColor = UIColor.label
    calendar.appearance.titleTodayColor = UIColor.label

    return calendar
  }

  func updateUIView(_ uiView: FSCalendar, context: Context) {
    uiView.reloadData()
  }

  class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
    var parent: CalendarView
    var albumViewModel: AlbumViewModel

    init(_ parent: CalendarView, albumViewModel: AlbumViewModel) {
      self.parent = parent
      self.albumViewModel = albumViewModel
    }

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
      let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! ImageCalendarCell
      if let records = albumViewModel.selectedAlbum?.records,
         let record = records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }),
         let image = if record.loadEditedImage() != nil { record.loadEditedImage()! } else { record.loadOriginalImage() } {
        cell.backImageView.image = image.resized(to: cell.backImageView.bounds.size)
      } else {
        cell.backImageView.image = nil
      }
      return cell
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
      if let record = albumViewModel.selectedAlbum?.records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
        parent.activeSheet = .detail(record: record)
      }
    }
  }
}
