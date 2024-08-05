//
//  SignInViewModel.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import Foundation

import RxSwift
import RxCocoa

final class SignInViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let onTouchSignInButton: ControlEvent<Void>
        let onTouchSignUpButton: ControlEvent<Void>
        let email: ControlProperty<String?>
        let password: ControlProperty<String?>
    }
    
    struct Output {
        let onTouchSignInButton: ControlEvent<Void>
        let onTouchSignUpButton: ControlEvent<Void>
        let emailValidationText: PublishRelay<String>
        let passwordValidationText: PublishRelay<String>
        let validationColor: PublishRelay<ValidationColor>
        let validationButtonTouch: PublishRelay<Bool>
    }
    
    func transform(for input: Input) -> Output {
        let emailValidationText = PublishRelay<String>()
        let passworValidationText = PublishRelay<String>()
        let validationColor = PublishRelay<ValidationColor>()
        let validationButtonTouch = PublishRelay<Bool>()
        
        
        let emailValidation = input.email.orEmpty
            .map { $0.count >= 3 &&  self.validateEmail(for: $0) }
            .share()
        
        let passwordValidation = input.password.orEmpty
            .map { $0.count >= 8 }
            .share()
        
        Observable.combineLatest([emailValidation, passwordValidation])
            .bind(with: self) { owner, validations in
                let isEnabled = (validations.filter { $0 == true }).count == validations.count
                
                validationButtonTouch.accept(isEnabled)
                validationColor.accept(isEnabled ? .valid : .error)
            }
            .disposed(by: disposeBag)
        
        emailValidation.bind(with: self) { owner, valid in
            emailValidationText.accept(valid ? "" : "이메일 비었거나 잘못됨")
        }
        .disposed(by: disposeBag)
        
        passwordValidation.bind(with: self) { owner, valid in
            passworValidationText.accept(valid ? "" : "비번 비었거나 잘못됨")
        }
        .disposed(by: disposeBag)
        
        return Output(
            onTouchSignInButton: input.onTouchSignInButton,
            onTouchSignUpButton: input.onTouchSignUpButton,
            emailValidationText: emailValidationText,
            passwordValidationText: passworValidationText,
            validationColor: validationColor,
            validationButtonTouch: validationButtonTouch
        )
    }
    
    private func validateEmail(for email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z._%-]+\\.[A-Za-z]{1,64}"
        return email.range(of: regex, options: .regularExpression) != nil
    }
}
