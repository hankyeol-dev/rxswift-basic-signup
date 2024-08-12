#  RxSwift, RxCocoa 기반으로 UI, Event를 다루는 앱

### 프로젝트 간단 소개

- RxSwift, RxCocoa를 통해 UI의 이벤트를 구독하고, 구독된 이벤트의 결과를 다시 구독 가능한 Observable로 반환하는 로직 작성에 집중하였습니다.
- `Input - Output 패턴`을 ViewModel, ViewController에 접목한 MVVM 구조로 작성하는데 집중하였습니다.


- 앱 스크린 샷

|1. 로그인 주소 검증 화면|2. 전화번호 검증 화면|3. 로그인 정보 검증 화면|
|-|-|-|
|<img width="200" src="https://github.com/user-attachments/assets/ffcf941b-3165-493e-8ccc-b63a9aa3bab2" />|<img width="200" src="https://github.com/user-attachments/assets/9262a676-a8c9-4a77-a273-0dda9b6bd37e" />|<img width="200" src="https://github.com/user-attachments/assets/e5fb2dbd-791e-4982-8ee7-a550125048c8" />|

<br />

|4. 쇼핑할 목록 추가/조회 화면|5. 아이튠즈 앱 검색 화면|6. 아이튠즈 앱 검색 화면 에러처리|7. 검색된 앱 상세 화면|
|-|-|-|
|<img width="160" src="https://github.com/user-attachments/assets/f6ad78be-aafd-4e9a-ad08-373a3b21b74b" />|<img width="160" src="https://github.com/user-attachments/assets/1aa4a593-42ad-415d-922e-0b5ba01e76c4" />|<img width="160" src="https://github.com/user-attachments/assets/bfd163e2-84fb-47c0-b0a8-53c6e7069f13" />|<img width="160" src="https://github.com/user-attachments/assets/7161d427-3639-4a32-96fa-6c59a1beb2bb" />|

<br />

### 프로젝트에서 고민한 것들

1. RxCocoa로 TableViewCell 안의 CollectionView를 다룰 때, delegate와 관련된 Warning Error 핸들링

<img width="400" "https://github.com/user-attachments/assets/0c66cff5-3b0d-4b1c-9a18-bfa2d222fa5b") />

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

2. Networking 통신을 할 때, Observable.onError를 통해 에러가 감지되면 UI단의 구독이 취소되는 것을 방지하고 에러 자체 핸들링하기

- textField에서 입력받은 검색어를 기반으로 네트워크 통신하는 searchData 메서드를 .map.subscribe 구문에서 처리했습니다.
    - api 통신이 원하는대로 되지 않을 수 있기 때문에, subscribe 구문에서 .onError 처리를 통해 에러를 넘겨줬습니다.
    - 다만, 이렇게 에러를 구독 단계에서 처리하는 경우, Input으로 들어온 이벤트의 스트림 자체가 dispose 되어 UI 이벤트 처리가 더이상 되지 않는 문제가 있었습니다.
    
    ```swift
    let list = PublishRelay<ItunesSearch>()
    let error = PublishRealy<ItunesNetworkError>()

    input.searchButtonTouched
        .withUnretained(self)
        .throttle(.seconds(2), scheduler: MainScheduler.instance)
        .withLatestFrom(input.searchBarText.orEmpty)
        .distinctUntilChanged()
        .map {
            self.searchData(for: $0)
        }
        .subscribe(with: self) { owner, emitter in
            emitter.bind(with: owner) { _, result in
                list.accept(result.results)
            }
            .disposed(by: owner.disposeBag)
        } onError: { _, e in
            error.accept(e)
        }
        .disposed(by: disposeBag)
    ```

- api 결과에 따른 구독 취소가 되지 않으면서, 에러 발생에 대한 결과를 유저에게 보여주기 위해 searchData 메서드의 반환 값을 ResultType으로 한 번 더 감싸주었습니다.
    - `Single<Result<Data, Error>>` 이런 형태로 반환 값을 맵핑하여 에러가 발생하는 경우에도 `.success(.failure(error))` 와 같은 형태로 에러가 발생하지 않은 것처럼 보여지도록 처리했습니다.
    - 네트워킹에 따른 에러가 구독 단계에서 에러로 인지되지 않는다면, UI단에서 시작된 구독 흐름이 취소되는 경우는 발생하지 않습니다. (onError 단계로 넘어갈 일이 없기 때문입니다.)
    
    ```swift
    // viewModel
    let apiResult = input.searchButtonTouched
        .withUnretained(self)
        .throttle(.seconds(2), scheduler: MainScheduler.instance)
        .withLatestFrom(input.searchBarText.orEmpty)
        .distinctUntilChanged()
        .flatMapLatest { searched in
            self.searchData(for: searched)
        }
        .share() // Observable 구독 공유 처리
    ```
    
    - 네트워킹 결과를 바로 Observable 형태로 생성해서 Output으로 VC에 넘겨주고, VC에서는 Output 객체를 조회해서 switch 구문을 통해 onNext로 넘어온 데이터나 에러 결과를 UI에 그려줄 수 있습니다.
    - switch 구문으로 구분해주는 것도 좋겠지만, success / failure 한 결과를 각각 Output 객체에 담아 보내주어 각각의 경우를 VC에서 뷰에 바인딩 할 수 있을 것 같습니다. 물론, 이럴 경우 넘겨주는 쪽에서 .share() 처리를 통해 구독이 공유될 수 있게 처리해주어야 원하는대로 Stream이 흘러갑니다.
        
        ```swift
        // viewModel
        let successObservable = apiResult
            .map { output -> [ItunesSearch] in
                guard case let .success(result) = output else {
                    return []
                }
                
                return result.results
            }
        ```

<br />

tbd
