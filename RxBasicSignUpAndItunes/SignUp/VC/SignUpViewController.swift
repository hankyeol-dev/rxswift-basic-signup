//
//  SignUpViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class SignUpViewController: UIViewController {
    
    // MARK: RX Variables
    private let disposeBag = DisposeBag()
    private let viewModel = SignUpViewModel()

    // MARK: View Objects
    private let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    private let emailValidationText = UILabel()
    private let validationButton = UIButton()
    private let nextButton = PointButton(title: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        bindView()
    }

    private func configure() {
        validationButton.setTitle("중복확인", for: .normal)
        validationButton.setTitleColor(Color.black, for: .normal)
        validationButton.layer.borderWidth = 1
        validationButton.layer.borderColor = Color.black.cgColor
        validationButton.layer.cornerRadius = 10
        
        emailTextField.keyboardType = .emailAddress
    }
    private func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(validationButton)
        view.addSubview(nextButton)
        view.addSubview(emailValidationText)
        
        validationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(100)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(validationButton.snp.leading).offset(-8)
        }
        
        emailValidationText.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

extension SignUpViewController {
    private func bindView() {
        
        let input = SignUpViewModel.Input(
            email: emailTextField.rx.text,
            onTouchNextButton: nextButton.rx.tap
        )
        
        let output = viewModel.transform(for: input)
        
        output.onTouchNextButton
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.validationColor
            .map {  $0.byColor }
            .bind(to: emailValidationText.rx.textColor, nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        output.validationColor
            .map { $0.byColor }
            .map { $0.cgColor }
            .bind(to: emailTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        output.isValid
            .bind(to: nextButton.rx.isEnabled, emailValidationText.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.validationText
            .bind(to: emailValidationText.rx.text)
            .disposed(by: disposeBag)
    }
}
