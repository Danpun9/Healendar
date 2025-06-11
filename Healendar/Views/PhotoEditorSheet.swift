import PhotoEditorSDK
import SwiftUI

/// 이미지를 편집하는 시트 뷰
struct PhotoEditorSheet: View {
  // 편집할 이미지 (바인딩되어 편집 결과를 상위 뷰에 반영)
  @Binding var image: UIImage?
  // 시트 닫기 위한 프레젠테이션 모드
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    // 이미지가 있으면 PhotoEditorSDK의 편집기 표시
    if let image = image {
      PhotoEditor(
        photo: .init(image: image)
      )
      // 편집 완료 시 호출
      .onDidSave { result in
        // 편집된 이미지 데이터로 UIImage 생성
        if let editedImage = UIImage(data: result.output.data) {
          self.image = editedImage // 상위 뷰에 편집 결과 반영
        }
        presentationMode.wrappedValue.dismiss() // 시트 닫기
      }
      // 취소 시 호출
      .onDidCancel {
        presentationMode.wrappedValue.dismiss() // 시트 닫기
      }
      // 편집 실패 시 호출
      .onDidFail { _ in
        presentationMode.wrappedValue.dismiss() // 시트 닫기
      }
      .ignoresSafeArea() // Safe Area 무시 (전체 화면 사용)
    }
  }
}
