import PhotoEditorSDK
import SwiftUI

struct PhotoEditorSheet: View {
  @Binding var image: UIImage?
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    if let image = image {
      PhotoEditor(
        photo: .init(image: image)
      )
      .onDidSave { result in
        if let editedImage = UIImage(data: result.output.data) {
          self.image = editedImage
        }
        presentationMode.wrappedValue.dismiss()
      }
      .onDidCancel {
        presentationMode.wrappedValue.dismiss()
      }
      .onDidFail { _ in
        presentationMode.wrappedValue.dismiss()
      }
      .ignoresSafeArea()
    }
  }
}
