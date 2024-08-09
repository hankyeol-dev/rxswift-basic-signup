//
//  ItunesDetailViewController.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/8/24.
//

import UIKit

import SnapKit
import RxSwift

final class ItunesDetailViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let appDetailView = UIView()
    
    private let appInfoBox = UIView()
    private let appIcon = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    private let appName = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        return view
    }()
    private let appCorp = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12, weight: .regular)
        view.textColor = .gray
        return view
    }()
    private let appButton: UIButton = {
        let button = UIButton()
        button.setTitle("받기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureView()
    }
    
    private func configureView() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(appDetailView)
        appDetailView.addSubview(appInfoBox)
        
        [appIcon, appName, appCorp, appButton].forEach {
            appInfoBox.addSubview($0)
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        appDetailView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.verticalEdges.equalTo(scrollView)
        }
        appInfoBox.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(appDetailView.safeAreaLayoutGuide)
            make.height.equalTo(150)
        }
        appIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(appInfoBox.safeAreaLayoutGuide).inset(16)
            make.size.equalTo(100)
        }
        [appName, appCorp, appButton].forEach {
            $0.snp.makeConstraints { make in
                make.leading.equalTo(appIcon.snp.trailing).offset(20)
            }
        }
        appName.snp.makeConstraints { make in
            make.top.equalTo(appInfoBox.safeAreaLayoutGuide).inset(25)
            make.trailing.equalTo(appInfoBox.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(28)
        }
        appCorp.snp.makeConstraints { make in
            make.bottom.equalTo(appButton.snp.top).offset(-4)
            make.trailing.equalTo(appInfoBox.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(16)
        }
        appButton.snp.makeConstraints { make in
            make.bottom.equalTo(appInfoBox.snp.bottom).offset(-25)
            make.width.equalTo(80)
            make.height.equalTo(36)
        }
    }
    
    func bindView(for data: ItunesSearch) {
        appIcon.load(url: URL(string: data.appIcon)!)
        appName.text = data.appName
        appCorp.text = data.developer
    }
    
}

final class ItunesDetailViewModel: ViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(for input: Input) -> Output {
        
        return Output()
    }
}
