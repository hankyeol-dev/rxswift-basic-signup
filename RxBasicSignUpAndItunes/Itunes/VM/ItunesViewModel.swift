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

final class ItunesViewModel: InputOutputProtocol {
    private let disposeBag = DisposeBag()
    private let shared = URLSession.shared
    
    struct Input {
        let searchBarText: ControlProperty<String?>
        let searchButtonTouched: ControlEvent<Void>
    }
    
    struct Output {
        let searchedItemList: Observable<[ItunesSearch]>
        let searchedError: Observable<ItunesNetworkError?>
    }
    
    func transform(for input: Input) -> Output {
        
        let apiResult = input.searchButtonTouched
            .withUnretained(self)
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchBarText.orEmpty)
            .distinctUntilChanged()
            .flatMapLatest { searched in
                self.searchData(for: searched)
            }
            .share()
        
        let successObservable = apiResult
            .map { output -> [ItunesSearch] in
                guard case let .success(result) = output else {
                    return []
                }
                
                return result.results
            }
        
        let failureObservable = apiResult
            .map { output -> ItunesNetworkError? in
                guard case let .failure(error) = output else {
                    return nil
                }
                return error
            }
        
        return Output(
            searchedItemList: successObservable,
            searchedError: failureObservable
        )
    }
    
    private func searchData(for term: String) -> Single<Result<ItunesSearchResult, ItunesNetworkError>> {
        let baseURL = "https://itunes.apple.com/search?media=software&country=KR&lang=ko_KR&limit=20&term="
        
        return Single.create { [weak self] emitter in
            guard let url = URL(string: baseURL + term) else {
                emitter(.success(.failure(.invalidURL)))
                return Disposables.create() // Disposable로 내보내서, 구독해서 사용할 수 있도록 처리
            }
            
            let task = self?.shared.dataTask(with: url) { data, res, error in
                guard error == nil else {
                    emitter(.success(.failure(.requestError)))
                    return
                }
                
                guard let res = res as? HTTPURLResponse,
                      (200...299).contains(res.statusCode) else {
                    emitter(.success(.failure(.responseError)))
                    return
                }
                
                guard let data,
                      let results = try? JSONDecoder().decode(ItunesSearchResult.self, from: data)
                else {
                    emitter(.success(.failure(.dataNotFound)))
                    return
                }
                
                emitter(.success(.success(results)))
            }
            
            task?.resume()
            
            return Disposables.create()
        }
    }
}
