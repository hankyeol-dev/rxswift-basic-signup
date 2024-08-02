//
//  PasswordViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class PasswordViewController: UIViewController {
    
    // MARK: RX
    private let disposeBag = DisposeBag()
    private let validationColor = PublishRelay<UIColor>()
    private let validationText = PublishRelay<String>()
    
    // MARK: View Objects
    private let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    private let passwordValidationText = UILabel()
    private let nextButton = PointButton(title: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        bindView()
    }
        
    private func configureLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(passwordValidationText)
        view.addSubview(nextButton)
         
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordValidationText.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordValidationText.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordTextField.isSecureTextEntry = true
    }

}

extension PasswordViewController {
    private func bindView() {
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PhoneViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        validationColor
            .bind(to: passwordValidationText.rx.textColor, nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        validationColor
            .map { $0.cgColor }
            .bind(to: passwordTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        validationText
            .bind(to: passwordValidationText.rx.text)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .map { $0.count >= 8 }
            .bind(with: self) { owner, valid in
                owner.validationColor.accept(valid ? .systemGreen : .systemRed)
                owner.nextButton.isEnabled = valid
                owner.validationText.accept(valid ? "유효한 비밀번호입니다." : "유효하지 않은 비밀번호입니다.")
            }
            .disposed(by: disposeBag)
    }
}
