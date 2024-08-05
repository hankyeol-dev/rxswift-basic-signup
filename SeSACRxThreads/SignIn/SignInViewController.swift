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
    
    private let viewModel = SignInViewModel()
    
    // MARK: RX
    private let disposeBag = DisposeBag()
    
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
        let input = SignInViewModel.Input(
            onTouchSignInButton: signInButton.rx.tap,
            onTouchSignUpButton: signUpButton.rx.tap,
            email: emailTextField.rx.text,
            password: passwordTextField.rx.text
        )
        
        let output = viewModel.transform(for: input)
        
        output.onTouchSignInButton
            .bind(with: self) { owner, _ in
                owner.dismissStack(for: ShoppingListViewController())
            }
            .disposed(by: disposeBag)
        
        output.onTouchSignUpButton
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(SignUpViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.emailValidationText
            .bind(to: emailValidationLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.emailValidationText
            .map { $0.count == 0 }
            .bind(to: emailValidationLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.passwordValidationText
            .bind(to: passwordValidationLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.passwordValidationText
            .map { $0.count == 0 }
            .bind(to: passwordValidationLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.validationColor
            .map { $0.byColor }
            .bind(to: signInButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        output.validationButtonTouch
            .bind(to: signInButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
