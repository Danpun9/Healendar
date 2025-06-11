import PhotosUI
import SwiftUI

/// 사진 기록을 생성/수정하는 편집 뷰 (새 기록 작성 및 기존 기록 수정 기능 통합)
struct RecordEditorView: View {
  // MARK: - Properties
    
  /// 앨범 데이터 관리 객체
  @ObservedObject var albumViewModel: AlbumViewModel
  /// 수정 모드일 경우 기존 기록 데이터
  let existingRecord: Record?
  /// 뷰 닫기 액션
  @Environment(\.dismiss) var dismiss
    
  // MARK: - 날짜 관리

  /// 기록의 날짜 (새 기록: 선택된 날짜/현재 날짜, 수정 모드: 기존 날짜)
  @State private var date: Date
    
  init(albumViewModel: AlbumViewModel, existingRecord: Record?) {
    self.albumViewModel = albumViewModel
    self.existingRecord = existingRecord
    // 날짜 초기값 설정: 기존 기록 > 선택된 날짜 > 현재 날짜 순
    self._date = State(initialValue: existingRecord?.date ?? albumViewModel.selectedDate ?? Date())
  }
    
  // MARK: - 이미지 관리

  /// PhotosPicker 선택 항목
  @State private var selectedItem: PhotosPickerItem?
  /// 원본 이미지 데이터 (필수)
  @State private var originalImageData: Data?
  /// 편집된 이미지 데이터 (옵셔널)
  @State private var editedImageData: Data?
  /// 사진 편집기 표시 상태
  @State private var showPhotoEditor = false
  /// 편집기에 전달할 이미지 객체
  @State private var photoImage: UIImage?
    
  // MARK: - 텍스트 관리

  /// 사용자 입력 설명 텍스트
  @State private var description: String = ""
    
  // MARK: - 태그 관리

  /// AI 생성/사용자 수정 태그 목록
  @State private var generatedTags: [String] = []
  /// 현재 편집 중인 태그
  @State private var editingTag: String?
  /// 태그 편집용 임시 저장소
  @State private var newTagText: String = ""
    
  // MARK: - Body

  var body: some View {
    VStack(spacing: 20) {
      // 이미지 표시 섹션
      imageDisplaySection
            
      // 태그 편집 섹션
      tagEditorSection
            
      // 사진 선택 버튼
      photoPickerSection
            
      // 설명 입력 필드
      descriptionInputSection
            
      // 저장 버튼
      saveButtonSection
    }
    .padding()
    .sheet(isPresented: $showPhotoEditor) { photoEditorSheet }
    .onAppear { loadExistingRecordData() }
  }
    
  // MARK: - Subviews
    
  /// 이미지 표시 영역 (편집본 우선 표시)
  private var imageDisplaySection: some View {
    Group {
      // 편집본 이미지 표시
      if let editedData = editedImageData, let uiImage = UIImage(data: editedData) {
        editableImage(uiImage)
      }
      // 원본 이미지 표시
      else if let originalData = originalImageData, let uiImage = UIImage(data: originalData) {
        editableImage(uiImage)
      }
      // 이미지 없을 때 플레이스홀더
      else {
        placeholderImage
      }
    }
  }
    
  /// 편집 가능한 이미지 뷰 (탭 제스처로 편집기 호출)
  private func editableImage(_ uiImage: UIImage) -> some View {
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
    
  /// 이미지 없을 때 표시할 기본 뷰
  private var placeholderImage: some View {
    Rectangle()
      .fill(Color.gray.opacity(0.2))
      .frame(height: 300)
      .overlay(Text("사진을 선택해 주세요").foregroundColor(.gray))
      .cornerRadius(12)
  }
    
  /// 태그 편집 영역 (가로 스크롤)
  private var tagEditorSection: some View {
    Group {
      if !generatedTags.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
          Text("생성된 태그")
            .font(.subheadline)
            .foregroundColor(.gray)
                    
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(generatedTags.indices, id: \.self) { index in
                // 개별 태그 뷰 (일반/편집 모드 전환)
                Group {
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
          }
          .frame(height: 40)
        }
        .padding(.horizontal)
      }
    }
  }
    
  /// 사진 선택 버튼 (PhotosPicker 통합)
  private var photoPickerSection: some View {
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
    .onChange(of: selectedItem) { handlePhotoSelection($0) }
  }
    
  /// 설명 입력 필드
  private var descriptionInputSection: some View {
    TextField("설명을 입력하세요", text: $description)
      .padding()
      .background(Color(.secondarySystemBackground))
      .cornerRadius(8)
  }
    
  /// 저장 버튼
  private var saveButtonSection: some View {
    Button(action: saveRecord) {
      Text("저장")
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
  }
    
  /// 사진 편집기 시트 (PhotoEditorSDK 통합)
  private var photoEditorSheet: some View {
    PhotoEditorSheet(
      image: Binding(
        get: { UIImage(data: editedImageData ?? Data()) },
        set: { newImage in
          if let newImage = newImage {
            editedImageData = newImage.jpegData(compressionQuality: 0.8)
          }
        }
      )
    )
  }
    
  // MARK: - Methods
    
  /// 기존 기록 데이터 로드 (수정 모드 전용)
  private func loadExistingRecordData() {
    guard let record = existingRecord else { return }
    description = record.description
    generatedTags = record.tags
        
    if let image = record.loadOriginalImage() {
      originalImageData = image.jpegData(compressionQuality: 0.8)
      editedImageData = originalImageData
    }
  }
    
  /// 사진 선택 처리 (비동기 작업)
  private func handlePhotoSelection(_ newItem: PhotosPickerItem?) {
    Task {
      if let data = try? await newItem?.loadTransferable(type: Data.self) {
        // 이미지 데이터 업데이트
        originalImageData = data
        editedImageData = data
                
        // AI 태그 생성
        if let image = UIImage(data: data) {
          generatedTags = ImageAnalyzer.shared.generateTags(image: image)
        }
      }
    }
  }
    
  /// 기록 저장 로직 (신규/수정 공용)
  private func saveRecord() {
    guard let originalData = originalImageData else { return }
        
    // 파일명 생성
    let originalFileName = "original_\(UUID().uuidString).jpg"
    let editedFileName = editedImageData != originalData ? "edited_\(UUID().uuidString).jpg" : nil
        
    // 새 기록 객체 생성
    let newRecord = Record(
      id: UUID(),
      date: date,
      originalImagePath: originalFileName,
      editedImagePath: editedFileName,
      description: description,
      tags: generatedTags
    )
        
    // 앨범에 기록 추가
    albumViewModel.addRecord(
      newRecord,
      originalData: originalData,
      editedData: editedImageData
    )
        
    // 기존 기록 삭제 (수정 모드 시)
    if let existingRecord {
      albumViewModel.deleteRecord(existingRecord)
    }
        
    dismiss() // 뷰 닫기
  }
}
