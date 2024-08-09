//
//  ShoppingListCell.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/2/24.
//

import UIKit

import SnapKit
import RxSwift

struct ShoppingListCellInput {
    let descript: String
    var isCompleted: Bool
    var isFavorited: Bool
}

final class ShoppingListCell: UITableViewCell {
    
    static let id = "ShoppingListCell"
    
    lazy var disposeBag = DisposeBag()
    
    private let back = UIView()
    let check = UIButton()
    private let label = UILabel()
    let favorite = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let guide = back.safeAreaLayoutGuide
        
        contentView.addSubview(back)
        [check, label, favorite].forEach {
            back.addSubview($0)
        }
        
        back.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(4)
        }
        
        check.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(guide).inset(12)
            make.size.equalTo(32)
        }
        
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(check.snp.trailing).offset(8)
            make.trailing.equalTo(favorite.snp.leading).offset(-8)
        }
        
        favorite.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(guide).inset(12)
            make.size.equalTo(32)
        }
        
        back.backgroundColor = .systemGray6
    }
    
    func bindCell(for data: ShoppingListCellInput) {
        check.setImage(data.isCompleted ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "checkmark.square"), for: .normal)
        check.tintColor = .blue
        
        favorite.setImage(data.isFavorited ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"), for: .normal)
        favorite.tintColor = .yellow
        
        label.text = data.descript
        label.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}
