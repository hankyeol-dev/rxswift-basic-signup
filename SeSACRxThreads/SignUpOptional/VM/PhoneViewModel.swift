//
//  PhoneViewModel.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/5/24.
//

import Foundation

import RxSwift
import RxCocoa

final class PhoneViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let phone: ControlProperty<String?>
        let onTouchNextButton: ControlEvent<Void>
    }
    
    struct Output {
        let phone: BehaviorRelay<String>
        let validationColor: PublishRelay<ValidationColor>
        let validationText: PublishRelay<String>
        let isValid: PublishRelay<Bool>
        let onTouchNextButton: ControlEvent<Void>
    }
    
    func transform(for input: Input) -> Output {
        let validationColor = PublishRelay<ValidationColor>()
        let phoneText = BehaviorRelay(value: "010")
        let validationText = PublishRelay<String>()
        let isValid = PublishRelay<Bool>()
        
        input.phone.orEmpty
            .bind(with: self) { _, text in
                if text.count == 3 || text.count == 8 {
                    phoneText.accept( text + "-" )
                }
            }
            .disposed(by: disposeBag)
        
        input.phone.orEmpty
            .map { self.validatePhoneNumber(for: $0) }
            .bind(with: self) { _, valid in
                validationColor.accept(valid ? .valid : .error)
                validationText.accept(valid ? "유효한 전화번호입니다." : "유효하지 않은 전화번호입니다.")
                isValid.accept(valid)
            }
            .disposed(by: disposeBag)
        
        return Output(
            phone: phoneText,
            validationColor: validationColor,
            validationText: validationText,
            isValid: isValid,
            onTouchNextButton: input.onTouchNextButton
        )
    }
    
    private func validatePhoneNumber(for email: String) -> Bool {
        let regex = "^010-[0-9]{4}-[0-9]{4}$"
        return email.range(of: regex, options: .regularExpression) != nil
    }
}


