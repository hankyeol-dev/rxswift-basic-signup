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
    private let viewModel = PhoneViewModel()
   
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
        let input = PhoneViewModel.Input(
            phone: phoneTextField.rx.text,
            onTouchNextButton: nextButton.rx.tap
        )
        
        let output = viewModel.transform(for: input)
        
        output.onTouchNextButton
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.validationColor
            .map { $0.byColor }
            .bind(to: phoneValidationText.rx.textColor, nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        output.validationColor
            .map { $0.byColor }
            .map { $0.cgColor }
            .bind(to: phoneTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        output.validationText
            .bind(to: phoneValidationText.rx.text)
            .disposed(by: disposeBag)
        
        output.phone
            .bind(to: phoneTextField.rx.text).disposed(by: disposeBag)
        
        output.isValid
            .bind(to: nextButton.rx.isEnabled, phoneValidationText.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func validatePhoneNumber(for email: String) -> Bool {
        let regex = "^010-[0-9]{4}-[0-9]{4}$"
        return email.range(of: regex, options: .regularExpression) != nil
    }
}
