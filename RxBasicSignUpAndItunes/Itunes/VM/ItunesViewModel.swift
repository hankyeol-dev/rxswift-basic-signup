//
//  ItunesViewModel.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/8/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol InputOutputProtocol: AnyObject {
    associatedtype Input
    associatedtype Output
    
    func transform(for input: Input) -> Output
}

enum ItunesNetworkError: Error {
    case invalidURL
    case requestError
    case responseError
    case dataNotFound
    
    var errorString: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL 요청입니다."
        case .requestError:
            return "요청에 문제가 있습니다."
        case .responseError:
            return "응답에 문제가 있습니다."
        case .dataNotFound:
            return "요청한 데이터를 찾을 수 없습니다."
        }
    }
}

// https://itunes.apple.com/lookup?id=387771637&lang=ko_KR
final class ItunesViewModel: InputOutputProtocol {
    private let disposeBag = DisposeBag()
    private let shared = URLSession.shared
    
    struct Input {
        let searchBarText: ControlProperty<String?>
        let searchButtonTouched: ControlEvent<Void>
    }
    
    struct Output {
        let searchedItemList: PublishRelay<[ItunesSearch]>
        let searchedError: PublishRelay<(any Error)?>
    }
    
    func transform(for input: Input) -> Output {
        
        let list = PublishRelay<[ItunesSearch]>()
        let error = PublishRelay<(any Error)?>()
        
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

        
        return Output(
            searchedItemList: list,
            searchedError: error
        )
    }
    
    func searchData(for term: String) -> Observable<ItunesSearchResult> {
        let baseURL = "https://itunes.apple.com/search?media=software&country=KR&lang=ko_KR&limit=20&term="
        
        return Observable<ItunesSearchResult>.create { [weak self] emitter in
            guard let url = URL(string: baseURL + term) else {
                emitter.onError(ItunesNetworkError.invalidURL)
                return Disposables.create() // Disposable로 내보내서, 구독해서 사용할 수 있도록 처리
            }
            
            let task = self?.shared.dataTask(with: url) { data, res, error in
                guard error == nil else {
                    emitter.onError(ItunesNetworkError.requestError)
                    return
                }
                
                guard let res = res as? HTTPURLResponse,
                      (200...299).contains(res.statusCode) else {
                    emitter.onError(ItunesNetworkError.responseError)
                    return
                }
                
                guard let data, let results = try? JSONDecoder().decode(ItunesSearchResult.self, from: data)
                else {
                    emitter.onError(ItunesNetworkError.dataNotFound)
                    return
                }
                
                emitter.onNext(results)
                emitter.onCompleted()
            }
                
            task?.resume()
            
            return Disposables.create()
        }
    }
}

/**
 {
       "artworkUrl512": "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/7a/a0/a3/7aa0a30c-717b-bd98-a327-babe3e32b40d/AppIconProd-0-0-1x_U007emarketing-0-5-0-85-220.png/512x512bb.jpg",
       "screenshotUrls": [
         "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/99/36/5d/99365d0e-d368-8a3a-8232-bbe2ca51d6e4/491c258f-6977-4077-b3b9-74e49c121609_IPHONE_1.png/392x696bb.png",
         "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/39/7f/83/397f83fc-61fc-dd15-78ab-b0fadcb353a0/5b5deb3f-72ea-474b-ad3a-a736a9f7df98_IPHONE_2.png/392x696bb.png",
         "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/a2/00/a8/a200a8db-7fbe-a227-83dc-06b58dfd948d/1a883377-5d67-4d5a-908e-aa6249abdf32_IPHONE_3.png/392x696bb.png",
         "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/0d/1b/81/0d1b81e0-5475-df45-08fc-1f695bc6571a/21b67312-bf97-4b37-9ce8-d784f630db0c_IPHONE_4.png/392x696bb.png",
         "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/0c/0b/f6/0c0bf6f4-3f15-fae3-c388-9af3c7f1cb2a/70968df4-a306-4978-b8c6-45b27fac25a1_IPHONE_5.png/392x696bb.png",
         "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/de/6f/31/de6f31cc-1ec6-d782-8174-547a5c18754e/6e49228b-0058-4023-b69a-167d719fa9d8_IPHONE_6.png/392x696bb.png",
         "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/59/17/1a/59171ab1-2ff1-7b25-cbfc-7ad711b178bd/2248ce77-1811-468b-b079-1bb45450db2c_IPHONE_7.png/392x696bb.png"
       ],
       "isGameCenterEnabled": false,
       "artistViewUrl": "https://apps.apple.com/kr/developer/nike-inc/id301521406?uo=4",
       "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/7a/a0/a3/7aa0a30c-717b-bd98-a327-babe3e32b40d/AppIconProd-0-0-1x_U007emarketing-0-5-0-85-220.png/60x60bb.jpg",
       "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/7a/a0/a3/7aa0a30c-717b-bd98-a327-babe3e32b40d/AppIconProd-0-0-1x_U007emarketing-0-5-0-85-220.png/100x100bb.jpg",
       "kind": "software",
       "averageUserRatingForCurrentVersion": 4.76895,
       "languageCodesISO2A": [
         "NL",
         "EN",
         "FR",
         "DE",
         "ID",
         "IT",
         "JA",
         "KO",
         "PT",
         "RU",
         "ZH",
         "ES",
         "SV",
         "TH",
         "ZH",
         "TR"
       ],
       "fileSizeBytes": "247339008",
       "sellerUrl": "https://www.nike.com/us/en_us/c/running/nike-run-club",
       "formattedPrice": "무료",
       "userRatingCountForCurrentVersion": 46393,
       "trackContentRating": "4+",
       "currentVersionReleaseDate": "2024-07-16T09:51:40Z",
       "releaseNotes": "버그 수정 및 기타 개선 사항",
       "artistId": 301521406,
       "artistName": "Nike, Inc",
       "genres": [
         "건강 및 피트니스",
         "스포츠"
       ],
       "price": 0,
       "description": "Nike Run Club: 더 나은 러닝을 위한 가이드\n\n5K~10K 트레이닝, 하프 마라톤 또는 그 이상꺼지 Nike Run Club 러닝 앱에는 러닝을 시작하고, 유지하며, 더 많은 러닝을 즐기는 데 필요한 모든 것이 있습니다. 운동 기록, 페이스 추적기, 거리 추적기, 러닝 가이드를 비롯한 여러 가지 도구가 있습니다.\n\n코치 또는 피트니스 커뮤니티 - NRC에는 운동 목표를 달성하기 위해 필요한 모든 것이 준비되어 있습니다. 나이키 커뮤니티에 참여하여 커뮤니티의 동료와 친구를 비롯한 많은 이들의 응원을 받아보세요. NRC 러닝 코치가 선택한 운동 팁과 러닝 가이드는 여러분이 자신감을 갖고 러닝을 시작하는 데 필요한 모든 도구를 제공합니다. 최고의 나이키 러닝 코치 또는 운동선수가 피트니스에 대한 의욕을 높이고, 러닝을 즐기는 데 도움이 되는 가이드를 제공합니다. 러닝 초급자를 위한 팁과 조언부터 하프 마라톤까지 - Nike Run Club은 모든 러닝을 아우릅니다.\n\nNRC의 러닝 가이드를 통해 나이키의 전문 러닝 코치, 그리고 나이키의 전설적인 인물들이 언제나 여러분 곁에 있습니다. 러닝할 때마다 언제나 용기를 주는 격려와 지도, 친숙한 목소리를 들어보세요. 5K 또는 10K, 저난도 또는 고난도, 장거리 또는 단거리, 그 어떤 러닝도 상관 없습니다. 거리나 목표와 무관하게 나에게 맞는 러닝 가이드를 활용해 보세요.\n\n장거리 트레이닝이든 단순한 취미 활동이든 상관없어요. 재미있는 챌린지를 만들어 지금 친구들과 공유해 보세요. 운동 앱 커뮤니티는 러닝과 피트니스를 더욱 보람 있게 만들어 줍니다.\n\n나이키 커뮤니티와 함께하는 러닝을 통해 운동이 더욱 즐거워집니다. Nike Run Club과 함께 목표를 달성하세요.\n\n러닝 추적기: 러닝 거리 추적 및 저장\n• 러닝 거리, 속도, GPS 경로, 고도 상승 및 심박수를 추적 및 저장\n• 5K, 10K 또는 하프 마라톤 - 거리 카운터와 러닝 로그로 진행 상황을 지속적으로 추적\n• 운동 타이머, 거리 추적기, 거리 카운터 및 페이스 추적기 기능을 통해 목표를 향해 매진 가능\n• 활동 추적기에서 Apple Watch 및 iOS 지원 기기로 운동 로그를 연동하여 연결 상태 유지\n\n오디오 가이드 런\n• 조깅에서 워킹까지 모든 운동 수준에 알맞은 러닝 가이드 제공• 달리는 동안 몸과 마음을 연결하는 데 도움을 주는 마음가짐 및 회복 관련 팁\n• 트레이너, 전문 코치, 엘리트 운동선수 또는 연예인 - 오디오 가이드 런을 통해 엘리우드 킵초게 및 톰 삭스와 같은 나이키 최고의 선수들로부터 동기와 영감 얻기\n• 러닝을 외롭지 않게 만들어 주는 NRC 러닝 가이드를 통한 러닝 코치의 지도\n• 더 힘차게 달리게 해주는 러닝 중 친구들의 음성 응원 듣기 및 나의 음성 응원 전송하기\n\n챌린지 참여를 통한 동기 부여\n• 5K~10K, 하프 마라톤 및 그 이상 - 개인 최고 기록 및 달성 기록에 대한 배지와 및 트로피 획득\n• 소셜 미디어 또는 메시지를 통해 사용자의 피트니스 커뮤니티와 공유 가능한 러닝 챌린지\n• 개인 기록을 경신하고 전 세계 러닝 클럽으로부터 온라인 하이파이브 받기\n• 주간 및 월간 NRC 거리 챌린지를 통해 스스로에게 도전하거나 나만의 챌린지를 만들고 친구 초대하기\n• 거리, 페이스 또는 그 이상 - 목표 및 성취를 향한 진행 상황을 추적하고 축하하기\n\n신발 태그 및 거리 카운터\n• 나이키를 포함한 모든 신발의 러닝 거리를 추적하기\n• 각 신발의 러닝 속도를 기록하여 어떤 신발을 신었을 때 가장 빠른 속도로 달렸는지 알아보기\n• 거리 설정 러닝, 트레이닝 또는 기타 - 새 신발이 필요할 때 나이키가 알림을 제공하므로 러닝에만 집중 가능\n\n피드\n• 손쉬운 운동: 트레이닝에 대한 전반적인 조언, 피트니스 커뮤니티 스토리 및 제품 출시 소식 받아보기\n• 나만의 페이스로 달리는 데 도움이 되는 러닝 및 그 밖의 운동에 대한 코치, 트레이너 및 운동선수의 팁\n• 친구들의 최신 피트니스 일정 확인\n• 나만의 활동 게시물 포스팅 및 게시물의 공개 범위 설정\n\nNike Run Club이 여러분의 모든 걸음을 응원합니다. 지금 다운로드하세요.\n\n--\n\nNike Run Club은 Apple 건강 앱과 연동하여 운동 기록을 동기화하고 심박수 데이터를 기록합니다.\n\nGPS를 백그라운드에서 계속해서 실행할 경우 배터리 수명이 단축될 수 있습니다.\n\nApple Music: 음악 라이브러리에 연결해 운동하는 동안 음악을 재생합니다.",
       "trackId": 387771637,
       "trackName": "Nike Run Club: 러닝 앱",
       "bundleId": "com.nike.nikeplus-gps",
       "sellerName": "Nike, Inc",
       "genreIds": [
         "6013",
         "6004"
       ],
       "releaseDate": "2010-09-06T07:00:00Z",
       "currency": "KRW",
       "primaryGenreName": "Health & Fitness",
       "primaryGenreId": 6013,
       "isVppDeviceBasedLicensingEnabled": true,
       "minimumOsVersion": "16.0",
       "averageUserRating": 4.76895,
       "trackCensoredName": "Nike Run Club: 러닝 앱",
       "trackViewUrl": "https://apps.apple.com/kr/app/nike-run-club-%EB%9F%AC%EB%8B%9D-%EC%95%B1/id387771637?uo=4",
       "contentAdvisoryRating": "4+",
       "version": "7.38.0",
       "wrapperType": "software",
       "userRatingCount": 46393
     }
 
 */
