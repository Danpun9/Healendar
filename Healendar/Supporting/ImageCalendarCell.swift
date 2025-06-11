import FSCalendar
import UIKit

class ImageCalendarCell: FSCalendarCell {
  var backImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 6
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.insertSubview(self.backImageView, at: 0)
    self.backImageView.frame = contentView.bounds.insetBy(dx: 2, dy: 2)

    shapeLayer.isHidden = true
  }

  required init!(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func configureAppearance() {
    super.configureAppearance()

    if isSelected {
      self.contentView.layer.borderWidth = 2
      self.contentView.layer.borderColor = UIColor.systemBlue.cgColor
    } else if dateIsToday {
      self.contentView.layer.borderWidth = 2
      self.contentView.layer.borderColor = UIColor.systemRed.cgColor
    } else {
      self.contentView.layer.borderWidth = 0
      self.contentView.layer.borderColor = UIColor.clear.cgColor
    }

    self.contentView.layer.cornerRadius = 6
    self.contentView.layer.masksToBounds = true
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.backImageView.image = nil
    self.contentView.layer.borderWidth = 0
  }
}
