//
//  ShoppingListViewModel.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/5/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol ViewModelType{
    associatedtype Input
    associatedtype Output
    
    func transform(for input: Input) -> Output
}

final class ShoppingListViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    
    private var shoppingList: [ShoppingListCellInput] = []
    private var shoppingRecommendList: [String] = ["키보드", "마우스", "짬뽕", "떡볶이", "맥북", "애플워치", "에어팟", "맥세이프충전기", "아이패드", "애플펜슬"]
    
    struct Input {
        let text: ControlProperty<String?>
        let onTouchListUpButton: ControlEvent<Void>
        let onTouchCheckButton: PublishRelay<Int>
        let onTouchFavoriteButton: PublishRelay<Int>
        let onTouchRecommendItem: PublishRelay<(Int, String)>
    }
    
    struct Output {
        let isCanListUp: PublishRelay<Bool>
        let list: BehaviorRelay<[ShoppingListCellInput]>
        let recommendList: BehaviorRelay<[String]>
        let onTouchListUpButton: ControlEvent<Void>
    }
    
    func transform(for input: Input) -> Output {
        let isCanListUp = PublishRelay<Bool>()
        let list = BehaviorRelay<[ShoppingListCellInput]>(value: shoppingList)
        let recommendList = BehaviorRelay<[String]>(value: shoppingRecommendList)
        var text = ""
        
        input.text.orEmpty
            .map { $0.count >= 1 }
            .bind(with: self) { _, valid in
                isCanListUp.accept(valid)
            }
            .disposed(by: disposeBag)
        
        input.text.orEmpty
            .bind(with: self) { _, value in
                text = value
            }
            .disposed(by: disposeBag)
        
        input.onTouchListUpButton
            .bind(with: self) { owner, _ in
                owner.shoppingList.insert(
                    ShoppingListCellInput(descript: text, isCompleted: false, isFavorited: false),
                    at: 0)
                list.accept(owner.shoppingList)
            }
            .disposed(by: disposeBag)

        input.onTouchCheckButton
            .bind(with: self) { owner, row in
                owner.shoppingList[row].isCompleted.toggle()
                list.accept(owner.shoppingList)
            }
            .disposed(by: disposeBag)
        
        input.onTouchFavoriteButton
            .bind(with: self) { owner, row in
                owner.shoppingList[row].isFavorited.toggle()
                list.accept(owner.shoppingList)
            }
            .disposed(by: disposeBag)
        
        input.onTouchRecommendItem
            .bind(with: self) { owner, tuple in
                // recommend 배열에서 제외하기
                owner.shoppingRecommendList.remove(at: tuple.0)
                // shoppingList 배열에 추가하기
                owner.shoppingList.insert(
                    ShoppingListCellInput(descript: tuple.1, isCompleted: false, isFavorited: false),
                    at: 0
                )
                
                // output에 반영하기
                list.accept(owner.shoppingList)
                recommendList.accept(owner.shoppingRecommendList)
            }
            .disposed(by: disposeBag)
        
        return Output(
            isCanListUp: isCanListUp,
            list: list,
            recommendList: recommendList,
            onTouchListUpButton: input.onTouchListUpButton
        )
    }
}
