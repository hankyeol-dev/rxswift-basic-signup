//
//  SignUpViewModel.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/5/24.
//

import Foundation

import RxSwift
import RxCocoa

final class SignUpViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let email: ControlProperty<String?>
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
        
        input.email.orEmpty
            .map { $0.count >= 3 && self.validateEmail(for: $0) }
            .bind(with: self) { owner, valid in
                validationColor.accept(valid ? .valid : .error)
                validationText.accept(valid ? "유효한 이메일입니다." : "유효하지 않은 이메일입니다.")
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
        
    private func validateEmail(for email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z._%-]+\\.[A-Za-z]{1,64}"
        return email.range(of: regex, options: .regularExpression) != nil
    }
}
