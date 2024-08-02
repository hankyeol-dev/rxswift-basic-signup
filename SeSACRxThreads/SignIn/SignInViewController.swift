//
//  SignInViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class SignInViewController: UIViewController {
    
    // MARK: RX
    private let disposeBag = DisposeBag()
    private let validationColor = PublishRelay<UIColor>()
    private let emailValidationText = PublishRelay<String>()
    private let passwordValidationText = PublishRelay<String>()
    
    // MARK: View Objects
    private let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    private let emailValidationLabel = UILabel()
    private let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    private let passwordValidationLabel = UILabel()
    private let signInButton = PointButton(title: "로그인")
    private let signUpButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        bindView()
    }

    private func configure() {
        signUpButton.setTitle("회원이 아니십니까?", for: .normal)
        signUpButton.setTitleColor(.systemBlue, for: .normal)
        
        emailTextField.keyboardType = .emailAddress
        emailValidationLabel.textColor = .systemRed
        passwordTextField.isSecureTextEntry = true
        passwordValidationLabel.textColor = .systemRed
    }
    private func configureLayout() {
        [emailTextField, emailValidationLabel, passwordTextField, passwordValidationLabel, signInButton, signUpButton].forEach {
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            }
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(120)
        }
        emailValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(6)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailValidationLabel.snp.bottom).offset(30)
        }
        
        passwordValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(6)
        }
        
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordValidationLabel.snp.bottom).offset(30)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(signInButton.snp.bottom).offset(16)
        }
    }
}

extension SignInViewController {
    private func bindView() {
        signInButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismissStack(for: ShoppingListViewController())
            }
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(SignUpViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        emailValidationText
            .bind(to: emailValidationLabel.rx.text)
            .disposed(by: disposeBag)
        
        passwordValidationText
            .bind(to: passwordValidationLabel.rx.text)
            .disposed(by: disposeBag)
        
        validationColor
            .bind(to: signInButton.rx.backgroundColor)
            .disposed(by: disposeBag)
                
        let emailValidation = emailTextField.rx.text.orEmpty
            .map { $0.count >= 3 && self.validateEmail(for: $0) }
        let passwordValidation = passwordTextField.rx.text.orEmpty
            .map { $0.count >= 8 }
        
        Observable.combineLatest([emailValidation, passwordValidation])
            .bind(with: self) { owner, validations in
                
                let isEnabled = (validations.filter { $0 == true }).count == validations.count
                
                owner.signInButton.isEnabled = isEnabled
                owner.validationColor.accept(isEnabled ? .systemGreen : .darkGray)
            }
            .disposed(by: disposeBag)
        
        emailValidation
            .bind(with: self) { owner, valid in
                owner.emailValidationText.accept(valid ? "" : "이메일 비었거나 잘못됨")
                owner.emailValidationLabel.isHidden = valid
            }
            .disposed(by: disposeBag)
        
        passwordValidation
            .bind(with: self) { owner, valid in
                owner.passwordValidationText.accept(valid ? "" : "비번 비었거나 잘못됨")
                owner.passwordValidationLabel.isHidden = valid
            }
            .disposed(by: disposeBag)
    }
}
