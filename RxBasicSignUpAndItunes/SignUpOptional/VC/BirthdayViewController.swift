//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
    
    // MARK: RX
    private let disposeBag = DisposeBag()
    private let validationColor = PublishRelay<UIColor>()
    private let validationText = PublishRelay<String>()
    private let birthText = PublishRelay<String>()
    
    // MARK: View Objects
    private let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    private let infoLabel = UILabel()
    private let birthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Color.black
        label.numberOfLines = 0
        return label
    }()
    private let nextButton = PointButton(title: "가입하기")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.white
        
        configureLayout()
        bindView()
    }
    
    private func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(birthLabel)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            $0.centerX.equalToSuperview()
        }
        
        birthLabel.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(birthLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

extension BirthdayViewController {
    private func bindView() {
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                let alert = UIAlertController(title: "회원가입 하실?", message: "진짜?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "네", style: .default, handler: { _ in
                    owner.dismissStack(for: SignInViewController())
                }))
                alert.addAction(UIAlertAction(title: "아니요", style: .cancel))
                
                owner.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
        
        validationColor
            .bind(to:
                    infoLabel.rx.textColor,
                  birthLabel.rx.textColor,
                  nextButton.rx.backgroundColor
            )
            .disposed(by: disposeBag)
        
        validationText
            .bind(to: infoLabel.rx.text)
            .disposed(by: disposeBag)
        
        birthText
            .bind(to: birthLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        birthDayPicker.rx.date.changed
            .distinctUntilChanged()
            .bind(with: self) { owner, date in
                let birthDay = Calendar.current.dateComponents([.year, .month, .day], from: date)
                let offset = Calendar.current.dateComponents([.year, .month, .day], from: date, to: Date())
                if let year = birthDay.year,
                   let month = birthDay.month,
                   let day = birthDay.day,
                   let age = offset.year {
                    
                    owner.birthText.accept("생년월일: \(year)년 \(month)월 \(day)일 \n (나이: \(age)살 \(age < 17 ? "부럽다)" : "어휴..)")")
                    if age >= 17 {
                        owner.validationText.accept("만 17세 이상이시군요. 늙으셨네요.^^")
                        owner.validationColor.accept(.systemBlue)
                        owner.nextButton.isEnabled = true
                    } else {
                        owner.validationText.accept("만 17세 미만은 가입할 수 없습니다. ^^")
                        owner.validationColor.accept(.systemRed)
                        owner.nextButton.isEnabled = false
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}
