import FSCalendar
import UIKit

/// FSCalendar의 커스텀 셀 - 이미지 배경과 선택 효과를 구현
class ImageCalendarCell: FSCalendarCell {
  // MARK: - UI Components

  /// 배경 이미지를 표시할 이미지 뷰
  var backImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill // 종횡비 유지하며 꽉 채움
    imageView.clipsToBounds = true // 경계 벗어난 이미지 자르기
    imageView.layer.cornerRadius = 6 // 둥근 모서리
    return imageView
  }()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.insertSubview(self.backImageView, at: 0) // 가장 하단 레이어에 추가
    self.backImageView.frame = contentView.bounds.insetBy(dx: 2, dy: 2) // 여백 2pt

    shapeLayer.isHidden = true // 기본 선택 효과 숨김
  }

  required init!(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Appearance Configuration

  /// 셀의 시각적 속성 설정 (선택/오늘 상태에 따라 변화)
  override func configureAppearance() {
    super.configureAppearance()

    // 선택 상태: 파란색 테두리
    if isSelected {
      self.contentView.layer.borderWidth = 2
      self.contentView.layer.borderColor = UIColor.systemBlue.cgColor
    }
    // 오늘 날짜: 빨간색 테두리
    else if dateIsToday {
      self.contentView.layer.borderWidth = 2
      self.contentView.layer.borderColor = UIColor.systemRed.cgColor
    }
    // 기본 상태: 테두리 없음
    else {
      self.contentView.layer.borderWidth = 0
      self.contentView.layer.borderColor = UIColor.clear.cgColor
    }

    self.contentView.layer.cornerRadius = 6 // 셀 모서리 둥글기
    self.contentView.layer.masksToBounds = true // 서브뷰 경계 제한
  }

  // MARK: - Reuse Preparation

  /// 셀 재사용 전 초기화 작업
  override func prepareForReuse() {
    super.prepareForReuse()
    self.backImageView.image = nil // 이미지 초기화
    self.contentView.layer.borderWidth = 0 // 테두리 초기화
  }
}
