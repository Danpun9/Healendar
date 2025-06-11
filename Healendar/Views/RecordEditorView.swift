import PhotosUI
import SwiftUI

struct RecordEditorView: View {
  @ObservedObject var albumViewModel: AlbumViewModel
  let existingRecord: Record?
  @Environment(\.dismiss) var dismiss

  @State private var selectedItem: PhotosPickerItem? = nil
  @State private var originalImageData: Data? = nil
  @State private var editedImageData: Data? = nil
  @State private var description: String = ""
  @State private var showPhotoEditor = false
  @State private var photoImage: UIImage?
  @State private var generatedTags: [String] = []
  @State private var editingTag: String? = nil
  @State private var newTagText: String = ""

  var body: some View {
    VStack(spacing: 20) {
      if let editedData = editedImageData, let uiImage = UIImage(data: editedData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .frame(height: 300)
          .cornerRadius(12)
          .onTapGesture {
            photoImage = uiImage
            showPhotoEditor = true
          }
      }
      else if let originalData = originalImageData, let uiImage = UIImage(data: originalData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .frame(height: 300)
          .cornerRadius(12)
          .onTapGesture {
            photoImage = uiImage
            showPhotoEditor = true
          }
      }
      else {
        Rectangle()
          .fill(Color.gray.opacity(0.2))
          .frame(height: 300)
          .overlay(Text("사진을 선택해 주세요").foregroundColor(.gray))
          .cornerRadius(12)
      }

      if !generatedTags.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
          Text("생성된 태그")
            .font(.subheadline)
            .foregroundColor(.gray)

          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(generatedTags.indices, id: \.self) { index in
                if editingTag == generatedTags[index] {
                  TextField("태그 입력", text: $newTagText, onCommit: {
                    generatedTags[index] = newTagText
                    editingTag = nil
                  })
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .frame(width: 120)
                }
                else {
                  Text("#\(generatedTags[index])")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                    .font(.caption)
                    .onTapGesture {
                      editingTag = generatedTags[index]
                      newTagText = generatedTags[index]
                    }
                }
              }
            }
          }
          .frame(height: 40)
        }
        .padding(.horizontal)
      }

      PhotosPicker(
        selection: $selectedItem,
        matching: .images,
        photoLibrary: .shared()
      ) {
        HStack {
          Image(systemName: "photo")
          Text("사진 선택")
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
      }
      .onChange(of: selectedItem) { newItem in
        Task {
          if let data = try? await newItem?.loadTransferable(type: Data.self) {
            originalImageData = data
            editedImageData = data

            if let image = UIImage(data: data) {
              let tags = ImageAnalyzer.shared.generateTags(image: image)
              DispatchQueue.main.async {
                generatedTags = tags
              }
            }
          }
        }
      }

      TextField("설명을 입력하세요", text: $description)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)

      Spacer()

      Button(action: {
        guard let originalData = originalImageData else { return }
        let originalFileName = "original_\(UUID().uuidString).jpg"
        let editedFileName = editedImageData != originalData ? "edited_\(UUID().uuidString).jpg" : nil
        let newRecord = Record(
          id: UUID(),
          date: Date(),
          originalImagePath: originalFileName,
          editedImagePath: editedFileName,
          description: description,
          tags: generatedTags
        )

        albumViewModel.addRecord(
          newRecord,
          originalData: originalData,
          editedData: editedImageData
        )

        if let existingRecord {
          albumViewModel.deleteRecord(existingRecord)
        }
        dismiss()
      }) {
        Text("저장")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
    }
    .padding()
    .sheet(isPresented: $showPhotoEditor) {
      if let editedData = editedImageData {
        PhotoEditorSheet(
          image: Binding(
            get: { UIImage(data: editedData) },
            set: { newImage in
              if let newImage = newImage {
                editedImageData = newImage.jpegData(compressionQuality: 0.8)
              }
            }
          )
        )
      }
    }
  }
}
