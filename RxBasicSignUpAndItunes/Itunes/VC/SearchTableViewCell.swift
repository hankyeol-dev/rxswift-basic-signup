//
//  SearchTableViewCell.swift
//  SeSACRxThreads
//
//  Created by jack on 8/1/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class SearchTableViewCell: UITableViewCell {
    private let disposeBag = DisposeBag()
    static let identifier = "SearchTableViewCell"
    
    let appTitleBox = UIView()
    let appNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    let appIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemMint
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    let downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("받기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.isUserInteractionEnabled = true
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 16
        return button
    }()
    
    let appInfoBox = UIView()
    let appRating = UILabel()
    let appCorp = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .systemGray3
        return view
    }()
    let appGenre = {
        let view = UILabel()
        view.textAlignment = .right
        return view
    }()
    
    let appScreenShotCollection = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 200)
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20)
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(ScreenShotItem.self, forCellWithReuseIdentifier: ScreenShotItem.id)
        return view
    }()
     
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    
    private func configure() {
        contentView.addSubview(appTitleBox)
        contentView.addSubview(appInfoBox)
        contentView.addSubview(appScreenShotCollection)
        
        [appNameLabel, appIconImageView, downloadButton].forEach {
            appTitleBox.addSubview($0)
        }
        
        [appRating, appCorp, appGenre].forEach {
            appInfoBox.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalTo(95)
            }
        }
        
        appTitleBox.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(80)
        }
        appIconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(20)
            $0.size.equalTo(60)
        }
        appNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(appIconImageView)
            $0.leading.equalTo(appIconImageView.snp.trailing).offset(20)
            $0.trailing.equalTo(downloadButton.snp.leading).offset(-8)
        }
        downloadButton.snp.makeConstraints {
            $0.centerY.equalTo(appIconImageView)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(32)
            $0.width.equalTo(72)
        }
        
        appInfoBox.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.top.equalTo(appTitleBox.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
        }
        appRating.snp.makeConstraints { make in
            make.leading.equalTo(20)
        }
        appCorp.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        appGenre.snp.makeConstraints { make in
            make.trailing.equalTo(appInfoBox.safeAreaLayoutGuide).inset(20)
        }
        
        appScreenShotCollection.snp.makeConstraints { make in
            make.top.equalTo(appInfoBox.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.height.equalTo(200)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
    }
    
    func bindCell(for data: ItunesSearch) {
        appIconImageView.load(url: URL(string: data.appIcon)!)
        appNameLabel.text = data.appName
        bindRatingString(for: appRating, by: data.getComputedRating)
        appCorp.text = data.developer
        appGenre.text = data.getGenre
        
        appScreenShotCollection.delegate = nil
        appScreenShotCollection.dataSource = nil
        Observable.just(data.screenshotUrls)
            .bind(to: appScreenShotCollection.rx.items(
                cellIdentifier: ScreenShotItem.id,
                cellType: ScreenShotItem.self)) { row, item, cell in
                cell.image.load(url: URL(string: item)!)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindRatingString(for target: UILabel, by text: String) {
        let attrString = NSMutableAttributedString(string: "")
        let starImage = NSTextAttachment(image: UIImage(systemName: "star.fill")!.withTintColor(.systemYellow, renderingMode: .alwaysTemplate))
        starImage.bounds = .init(x: 0, y: -2, width: 15, height: 15)
        attrString.append(NSAttributedString(attachment: starImage))
        attrString.append(NSAttributedString(string: " " + text))
        
        target.attributedText = attrString
    }
}

final class ScreenShotItem: UICollectionViewCell {
    static let id = "ScreenShotItem"
    
    let image = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(image)
        image.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        image.contentMode = .scaleAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
