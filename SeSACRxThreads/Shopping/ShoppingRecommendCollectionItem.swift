//
//  ShoppingRecommendCollectionItem.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/7/24.
//

import UIKit
import SnapKit

final class ShoppingRecommendCollectionItem: UICollectionViewCell {
    static let id = "ShoppingRecommendCollectionItem"
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = .black
        label.textColor = .white
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
    }
    
    func setLabel(for text: String) {
        label.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
