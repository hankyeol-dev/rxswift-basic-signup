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
//    private let listData = BehaviorRelay<[ShoppingListCellInput]>(value: [])
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "shopping list"
        
        configure()
        bindView()
    }

    private func configure() {
        [field, button, table].forEach {
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
        
        table.snp.makeConstraints { make in
            make.top.equalTo(field.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        table.separatorStyle = .none
    }
}

extension ShoppingListViewController {
    private func bindView() {
        let input = ShoppingListViewModel.Input(
            text: field.rx.text,
            onTouchListUpButton: button.rx.tap
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
                to: table.rx.items(cellIdentifier: ShoppingListCell.id, cellType: ShoppingListCell.self)
            ) { row, data, cell in
                cell.bindCell(for: data)
                
                cell.check.rx.tap
                    .bind(with: self) { owner, _ in
                        var datas = data
                        datas
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
//        listData
//            .bind(
//                to: table.rx.items(cellIdentifier: ShoppingListCell.id, cellType: ShoppingListCell.self)
//            ) { row, data, cell in
//                
//               
//                cell.bindCell(for: data)
//                cell.check.rx.tap
//                    .bind(with: self) { owner, _ in
//                        var datas = owner.listData.value
//                        datas = datas.enumerated().map { i, v in
//                            if i == row {
//                                return ShoppingListCellInput(descript: v.descript, isCompleted: !v.isCompleted, isFavorited: v.isFavorited)
//                            } else {
//                                return v
//                            }
//                        }
//                        owner.listData.accept(datas)
//                    }
//                    .disposed(by: cell.disposeBag)
//                cell.favorite.rx.tap
//                    .bind(with: self) { owner, _ in
//                        var datas = owner.listData.value
//                        datas = datas.enumerated().map { i, v in
//                            if i == row {
//                                return ShoppingListCellInput(descript: v.descript, isCompleted: v.isCompleted, isFavorited: !v.isFavorited)
//                            } else {
//                                return v
//                            }
//                        }
//                        owner.listData.accept(datas)
//                    }
//                    .disposed(by: cell.disposeBag)
//            }
//            .disposed(by: disposeBag)

    }
}
