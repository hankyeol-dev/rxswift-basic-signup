//
//  ShoppingListViewController.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/2/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

// realm vs diffableDatasource 함께 쓸 때?
// diffableDatasource snapshotusingreloaddata

final class ShoppingListViewController: UIViewController {
    
    // MARK: RX
    private let disposeBag = DisposeBag()
    private let viewModel = ShoppingListViewModel()
    
    
    // MARK: View Objects
    private let field = {
        let f = UITextField()
        f.placeholder = "추가하기"
        return f
    }()
    private let button = {
        let b = UIButton()
        b.setTitle("추가", for: .normal)
        b.backgroundColor = .black
        b.titleLabel?.textColor = .white
        return b
    }()
    private let table = {
        let t = UITableView()
        t.register(ShoppingListCell.self, forCellReuseIdentifier: ShoppingListCell.id)
        t.rowHeight = 80
        return t
    }()
    private let collection = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 44)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ShoppingRecommendCollectionItem.self, forCellWithReuseIdentifier: ShoppingRecommendCollectionItem.id)
        
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "shopping list"
        
        configure()
        bindView()
    }

    private func configure() {
        [field, button, collection, table].forEach {
            view.addSubview($0)
        }
        
        field.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.trailing.equalTo(button.snp.leading).offset(-8)
            make.height.equalTo(44)
        }
        
        button.snp.makeConstraints { make in
            make.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(44)
            make.width.equalTo(56)
        }
        
        field.borderStyle = .roundedRect
        
        collection.snp.makeConstraints { make in
            make.top.equalTo(field.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(44)
        }
        
        table.snp.makeConstraints { make in
            make.top.equalTo(collection.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        table.separatorStyle = .none
    }
}

extension ShoppingListViewController {
    private func bindView() {
        let checkButtonIndex = PublishRelay<Int>()
        let favoriteButtonIndex = PublishRelay<Int>()
        let recommendItemTuple = PublishRelay<(Int, String)>()
        
        let input = ShoppingListViewModel.Input(
            text: field.rx.text,
            onTouchListUpButton: button.rx.tap,
            onTouchCheckButton: checkButtonIndex,
            onTouchFavoriteButton: favoriteButtonIndex,
            onTouchRecommendItem: recommendItemTuple
        )
        let output = viewModel.transform(for: input)
        
        output.isCanListUp
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.onTouchListUpButton
            .bind(with: self, onNext: { owner, _ in
                owner.field.text = ""
                owner.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        output.list
            .bind(
                to: table.rx.items(
                    cellIdentifier: ShoppingListCell.id,
                    cellType: ShoppingListCell.self)
            ) { row, data, cell in
                cell.bindCell(for: data)
                cell.check.rx.tap
                    .bind(with: self) { _,_ in
                        checkButtonIndex.accept(row)
                    }
                    .disposed(by: cell.disposeBag)
                cell.favorite.rx.tap
                    .bind(with: self) { _,_ in
                        favoriteButtonIndex.accept(row)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.recommendList
            .bind(
                to: collection.rx.items(
                    cellIdentifier: ShoppingRecommendCollectionItem.id,
                    cellType: ShoppingRecommendCollectionItem.self)
            ) { row, data, item in
                item.setLabel(for: data)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(
            collection.rx.itemSelected,
            collection.rx.modelSelected(String.self)
        )
        .bind(with: self) { owner, elementTuple in
            recommendItemTuple.accept((elementTuple.0.row, elementTuple.1))
        }
        .disposed(by: disposeBag)
    }
}
