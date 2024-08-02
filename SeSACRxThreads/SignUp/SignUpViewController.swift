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
    private let validationColor = PublishRelay<UIColor>()
    private let validationText = PublishRelay<String>()

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
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        validationColor
            .bind(to: emailValidationText.rx.textColor, nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        validationColor
            .map { $0.cgColor }
            .bind(to: emailTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        validationText
            .bind(to: emailValidationText.rx.text)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text.orEmpty
            .map { $0.count >= 3 && self.validateEmail(for: $0) }
            .bind(with: self) { owner, valid in
                owner.validationColor.accept(valid ? .systemGreen : .systemRed)
                owner.nextButton.isEnabled = valid
                owner.validationText.accept(valid ? "유효한 이메일입니다." : "유효하지 않은 이메일입니다.")
            }
            .disposed(by: disposeBag)
    }
    
    private func validateEmail(for email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z._%-]+\\.[A-Za-z]{1,64}"
        return email.range(of: regex, options: .regularExpression) != nil
    }
}
