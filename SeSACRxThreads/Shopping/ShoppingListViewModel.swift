//
//  ShoppingListViewModel.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/5/24.
//

import Foundation

import RxSwift
import RxCocoa

final class ShoppingListViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let text: ControlProperty<String?>
        let onTouchListUpButton: ControlEvent<Void>
//        let onTouchCheckButton: ControlEvent<Void>
//        let onTouchFavoriteButton: ControlEvent<Void>
    }
    
    struct Output {
        let isCanListUp: PublishRelay<Bool>
        let list: BehaviorRelay<[ShoppingListCellInput]>
        let onTouchListUpButton: ControlEvent<Void>
    }
    
    func transform(for input: Input) -> Output {
        let isCanListUp = PublishRelay<Bool>()
        let list = BehaviorRelay<[ShoppingListCellInput]>(value: [])
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
                var datas = list.value
                datas.insert(
                    ShoppingListCellInput(
                        descript: text,
                        isCompleted: false, isFavorited: false), 
                    at: 0
                )
                list.accept(datas)
            }
            .disposed(by: disposeBag)
        
//        input.onTouchCheckButton
//            .bind(with: self) { _,_ in
//                var datas = list.value
//                datas = datas.enumerated().map { i, v in
//                    if i == row {
//                        return ShoppingListCellInput(descript: v.descript, isCompleted: !v.isCompleted, isFavorited: v.isFavorited)
//                    } else {
//                        return v
//                    }
//                }
//                list.accept(datas)
//            }
//            .disposed(by: disposeBag)
        
        return Output(
            isCanListUp: isCanListUp,
            list: list,
            onTouchListUpButton: input.onTouchListUpButton
        )
    }
}
