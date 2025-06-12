![Image](https://github.com/user-attachments/assets/372784b2-1dc4-451d-a23b-370254bb1af6)
# Healendar

Healendar는 사용자 사진 문서화와 기록 관리를 위한 iOS 앱입니다.  
사진 업로드, 편집, 태그 관리, 달력 기반 기록 검색 등 직관적인 인터페이스와 쉬운 편집 기능을 제공합니다.

## 주요 기능

- **앨범 생성 및 관리**: 여러 앨범을 생성하고 순서 변경, 삭제가 가능합니다.
- **사진 업로드 및 편집**: 사진을 선택해 기록에 추가하고, 자체 편집 기능을 지원합니다.
- **기록 작성**: 사진과 함께 설명, 태그, 날짜를 입력해 기록을 관리합니다.
- **태그 검색**: 기록에 추가된 태그를 클릭하면 동일 태그를 가진 다른 기록을 볼 수 있습니다.
- **달력 기반 검색**: 달력에서 날짜를 선택해 해당 날짜의 기록을 추가하거나 확인할 수 있습니다.
- **선택 기록 삭제**: 기록을 삭제할 수 있습니다.
- **앨범 순서 변경**: 드래그 앤 드롭으로 앨범 순서를 바꿀 수 있습니다.
- **앨범 삭제**: 더 이상 필요 없는 앨범은 삭제할 수 있습니다.

## 기술 스택

- **SwiftUI**: 직관적이고 현대적인 UI 구현
- **PhotosUI**: 사진 선택 및 업로드
- **Core ML**: 이미지 분석 및 태그 자동 생성
- **FileManager**: 파일 기반 데이터 관리
- **JSON**: 앨범 및 기록 데이터 저장 및 불러오기
- **FSCalendar**: 달력 UI 및 날짜 선택 기능
- **PhotoEditorSDK**: 사진 편집 기능

## 사용 방법

1. **앨범 생성**

<img src="https://github.com/user-attachments/assets/6a36c634-36a7-4e87-a640-c1fc5e3e3e4f" width="50%">

<img src="https://github.com/user-attachments/assets/689b27ba-b44f-4613-845a-5b2fbd340202" width="50%">

   - 앨범 선택 화면에서 새 앨범을 생성합니다.
   
   
2. **오늘 기록 추가, 선택 날짜 기록 추가**

<img src="https://github.com/user-attachments/assets/4d9341e0-18ef-478a-bb93-c88379faf89d" width="50%">

<img src="https://github.com/user-attachments/assets/b9545286-aa05-4ad0-8024-19c7b8dcc740" width="50%">

   - 오늘 날짜 또는 달력에서 선택한 날짜에 기록을 추가할 수 있습니다.
   
   
3. **사진 편집**

<img src="https://github.com/user-attachments/assets/4d9341e0-18ef-478a-bb93-c88379faf89d" width="50%">

   - 사진을 선택한 후, 편집 기능을 통해 이미지를 수정할 수 있습니다.
   

4. **기록 작성**

<img src="https://github.com/user-attachments/assets/cf53d23a-6d27-4c74-a038-b632694e2c59" width="50%">

   - 사진과 함께 설명, 태그, 날짜를 입력해 기록을 저장합니다.
   
   
5. **태그 검색**

<img src="https://github.com/user-attachments/assets/260ec402-6162-4dc3-8570-2a116acda653" width="50%">

<img src="https://github.com/user-attachments/assets/f12653c9-bd33-4bc7-8a57-f0ba40d021d7" width="50%">

   - 기록에 추가된 태그를 클릭하면 동일 태그를 가진 다른 기록을 볼 수 있습니다.
   
   
6. **선택 기록 삭제**

<img src="https://github.com/user-attachments/assets/90c21a19-5f4a-4db2-a52f-366736cb43a4" width="50%">

   - 기록 상세 화면에서 기록을 삭제할 수 있습니다.
   
   
7. **앨범 순서 변경**

<img src="https://github.com/user-attachments/assets/f28a683c-46a1-4973-a8a5-34cb598b1a94" width="50%">

   - 앨범 리스트에서 드래그 앤 드롭으로 순서를 변경할 수 있습니다.
   
   
8. **앨범 삭제**

<img src="https://github.com/user-attachments/assets/6deb223b-0028-40b7-a232-1335575bdb7e" width="50%">

   - 앨범 리스트에서 앨범을 삭제할 수 있습니다.
   

## 파일 구조

```
Healendar/
├── Models/
│ ├── Album.swift // 앨범 모델
│ ├── Record.swift // 기록 모델
│ └── ...
├── ViewModels/
│ ├── AlbumViewModel.swift // 앨범 데이터 관리
│ └── ...
├── Views/
│ ├── MainView.swift // 메인 뷰
│ ├── RecordEditorView.swift // 기록 편집 뷰
│ ├── RecordDetailView.swift // 기록 상세 뷰
│ ├── FullScreenImageView // 풀 스크린 뷰
│ ├── AlbumListView.swift // 앨범 리스트 뷰
│ ├── TagSearchView.swift // 태그 검색 뷰
│ ├── TaggedRecordListView.swift // 태그별 기록 리스트 뷰
│ ├── CalendarView.swift // 달력 뷰
│ └── ...
├── Helpers/
│ ├── ImageAnalyzer.swift // 이미지 분석 및 태그 생성
│ └── ...
└── App/
└── HealendarApp.swift // 앱 엔트리 포인트
