import SwiftUI

struct FullScreenImageView: View {
  let image: UIImage
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()
      Image(uiImage: image)
        .resizable()
        .scaledToFit()
        .gesture(
          TapGesture().onEnded {
            dismiss()
          }
        )
    }
  }
}
