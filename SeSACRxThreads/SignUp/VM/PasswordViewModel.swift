//
//  PasswordViewModel.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/5/24.
//

import Foundation

import RxSwift
import RxCocoa

final class PasswordViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let password: ControlProperty<String?>
        let onTouchNextButton: ControlEvent<Void>
    }
    
    struct Output {
        let validationColor: PublishRelay<ValidationColor>
        let validationText: PublishRelay<String>
        let isValid: PublishRelay<Bool>
        let onTouchNextButton: ControlEvent<Void>
    }
    
    func transform(for input: Input) -> Output {
        let validationColor = PublishRelay<ValidationColor>()
        let validationText = PublishRelay<String>()
        let isValid = PublishRelay<Bool>()
        
        input.password.orEmpty
            .map { $0.count >= 8 }
            .bind(with: self) { owner, valid in
                validationColor.accept(valid ? .valid : .error)
                validationText.accept(valid ? "유효한 비밀번호입니다." : "유효하지 않은 비밀번호입니다.")
                isValid.accept(valid)
            }
            .disposed(by: disposeBag)
        
        return Output(
            validationColor: validationColor,
            validationText: validationText,
            isValid: isValid,
            onTouchNextButton: input.onTouchNextButton
        )
    }
}

