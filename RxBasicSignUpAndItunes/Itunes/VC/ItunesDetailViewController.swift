//
//  ItunesDetailViewController.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/8/24.
//

import UIKit

import SnapKit
import SnapKit
import RxSwift

final class ItunesDetailViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
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
    
    private let appNewsView = UIView()
    private let appNewsTitle = {
        let view = UILabel()
        view.text = "새로운 소식"
        view.font = .systemFont(ofSize: 14, weight: .semibold)
        return view
    }()
    private let appNewsVersion = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13, weight: .semibold)
        view.textColor = .darkGray
        return view
    }()
    private let appNews = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 13, weight: .regular)
        view.textColor = .gray
        return view
    }()
    
    private let appScreenShotCollection = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 160, height: 240)
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20)
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(ScreenShotItem.self, forCellWithReuseIdentifier: ScreenShotItem.id)
        return view
    }()
    
    private let appDescription = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .semibold)
        view.textColor = .darkGray
        view.numberOfLines = 0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureDetailView()
        configureHeaderView()
        configureAppNewsView()
        configureScreenShotView()
        configureDescriptionView()
    }
    
    private func configureDetailView() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(appDetailView)
        
        [appInfoBox, appNewsView, appScreenShotCollection, appDescription].forEach {
            appDetailView.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        appDetailView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.verticalEdges.equalTo(scrollView)
        }
        
    }
    private func configureHeaderView() {
        [appIcon, appName, appCorp, appButton].forEach {
            appInfoBox.addSubview($0)
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
    private func configureAppNewsView() {
        appNewsView.addSubview(appNewsTitle)
        appNewsView.addSubview(appNewsVersion)
        appNewsView.addSubview(appNews)
        
        appNewsView.snp.makeConstraints { make in
            make.top.equalTo(appInfoBox.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(appDetailView.safeAreaLayoutGuide)
            make.bottom.equalTo(appScreenShotCollection.snp.top).offset(-8)
        }
        appNewsTitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalTo(appNewsView.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(20)
        }
        appNewsVersion.snp.makeConstraints { make in
            make.top.equalTo(appNewsTitle.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(appNewsView.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(20)
        }
        appNews.snp.makeConstraints { make in
            make.top.equalTo(appNewsVersion.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(appNewsView.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(appNewsView.safeAreaLayoutGuide).inset(4)
        }
    }
    private func configureScreenShotView() {
        appScreenShotCollection.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(appDetailView.safeAreaLayoutGuide)
            make.height.equalTo(280)
        }
    }
    private func configureDescriptionView() {
        appDescription.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(appDetailView.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(appScreenShotCollection.snp.bottom).offset(16)
        }
    }
    
    func bindView(for data: ItunesSearch) {
        appIcon.load(url: URL(string: data.appIcon)!)
        appName.text = data.appName
        appCorp.text = data.developer
        appNewsVersion.text = "버전 " + data.version
        appNews.text = data.releaseNotes
        
        appScreenShotCollection.delegate = nil
        appScreenShotCollection.dataSource = nil
        
        Observable.just(data.screenshotUrls)
            .bind(to: appScreenShotCollection.rx.items(cellIdentifier: ScreenShotItem.id, cellType: ScreenShotItem.self)) { row, item, cell in
                cell.image.load(url: URL(string: item)!)
            }
            .disposed(by: disposeBag)
        
        appDescription.text = data.description
    }
    
}
