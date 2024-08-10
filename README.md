#  RxSwift, RxCocoa 기반으로 UI, Event를 다루는 앱

### 프로젝트 간단 소개

- RxSwift, RxCocoa를 통해 UI의 이벤트를 구독하고, 구독된 이벤트의 결과를 다시 구독 가능한 Observable로 반환하는 로직 작성에 집중하였습니다.
- `Input - Output 패턴`을 ViewModel, ViewController에 접목한 MVVM 구조로 작성하는데 집중하였습니다.


- 앱 스크린 샷

|1. 로그인 주소 검증 화면|2. 전화번호 검증 화면|3. 로그인 정보 검증 화면|
|-|-|-|
|<img width="200" src="https://github.com/user-attachments/assets/ffcf941b-3165-493e-8ccc-b63a9aa3bab2" />|<img width="200" src="https://github.com/user-attachments/assets/9262a676-a8c9-4a77-a273-0dda9b6bd37e" />|<img width="200" src="https://github.com/user-attachments/assets/e5fb2dbd-791e-4982-8ee7-a550125048c8" />|

<br />

|4. 쇼핑할 목록 추가/조회 화면|5. 아이튠즈 앱 검색 화면|6. 검색된 앱 상세 화면|
|-|-|-|
|<img width="200" src="https://github.com/user-attachments/assets/f6ad78be-aafd-4e9a-ad08-373a3b21b74b" />|<img width="200" src="https://github.com/user-attachments/assets/1aa4a593-42ad-415d-922e-0b5ba01e76c4" />|<img width="200" src="https://github.com/user-attachments/assets/7161d427-3639-4a32-96fa-6c59a1beb2bb" />|

<br />

### 프로젝트에서 고민한 것들

1. RxCocoa로 TableViewCell 안의 CollectionView를 다룰 때, delegate와 관련된 Warning Error 핸들링

<img width="100%" "https://github.com/user-attachments/assets/0c66cff5-3b0d-4b1c-9a18-bfa2d222fa5b") />

- 터미널에 찍힌 에러 코멘트에서는 혹시 개발자가 의도하지 않게 이전에 설정해준 delegation이 있을 수 있어 원하는 대로 Observable subscribing이 되지 않을 수 있다는 것을 알려주고 있었습니다.
- 컬렉션뷰에 대한 delegate, dataSource와 관련한 protocol 채택이 없었지만, 컬렉션뷰에 넘겨줄 데이터 Observable을 binding 하는 코드 전에 delegate, dataSource 값을 nil로 할당하는 코드를 넣어 에러를 방지할 수 있었습니다.

```swift
appScreenShotCollection.delegate = nil
appScreenShotCollection.dataSource = nil

Observable.just(data.screenshotUrls)
    .bind(to: appScreenShotCollection.rx.items(
        cellIdentifier: ScreenShotItem.id,
        cellType: ScreenShotItem.self)) { row, item, cell in
        cell.image.load(url: URL(string: item)!)
    }
    .disposed(by: disposeBag)
```

(tbd)
