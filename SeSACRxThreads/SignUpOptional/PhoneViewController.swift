//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class PhoneViewController: UIViewController {
    
    // MARK: RX
    private let disposeBag = DisposeBag()
    private let validationColor = PublishRelay<UIColor>()
    private let validationText = PublishRelay<String>()
    private let phoneText = BehaviorRelay(value: "010")
   
    // MARK: View Objects
    private let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    private let phoneValidationText = UILabel()
    private let nextButton = PointButton(title: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        configureLayout()
        bindView()
    }

    
    private func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(phoneValidationText)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        phoneValidationText.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneValidationText.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        phoneTextField.keyboardType = .numberPad
    }

}

extension PhoneViewController {
    private func bindView() {
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        validationColor
            .bind(to: phoneValidationText.rx.textColor, nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        validationColor
            .map { $0.cgColor }
            .bind(to: phoneTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        validationText
            .bind(to: phoneValidationText.rx.text)
            .disposed(by: disposeBag)
        
        phoneText
            .bind(to: phoneTextField.rx.text).disposed(by: disposeBag)
        
        phoneTextField.rx.text.orEmpty
            .bind(with: self) { owner, text in
                if text.count == 3 || text.count == 8 {
                    owner.phoneText.accept( text + "-" )
                }
            }
            .disposed(by: disposeBag)
        
        phoneTextField.rx.text.orEmpty
            .map { self.validatePhoneNumber(for: $0) }
            .bind(with: self) { owner, valid in
                owner.validationColor.accept(valid ? .systemGreen : .systemRed)
                owner.validationText.accept(valid ? "유효한 전화번호입니다." : "유효하지 않은 전화번호입니다.")
                owner.nextButton.isEnabled = valid
            }
            .disposed(by: disposeBag)
    }
    
    private func validatePhoneNumber(for email: String) -> Bool {
        let regex = "^010-[0-9]{4}-[0-9]{4}$"
        return email.range(of: regex, options: .regularExpression) != nil
    }
}
