//
//  ItunesViewController.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/8/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class ItunesViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = ItunesViewModel()

    private let searchBar = {
        let view = UISearchBar()
        view.placeholder = "원하는 앱을 검색해보세요."
        view.tintColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureNav()
        configureView()
        bindView()
    }
    
    private func configureNav() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "검색"
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    private func configureView() {
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
    }
    
    private func bindView() {
        
        let input = ItunesViewModel.Input(
            searchBarText: searchBar.rx.text,
            searchButtonTouched: searchBar.rx.searchButtonClicked
        )
        
        let output = viewModel.transform(for: input)
        
        searchBar.rx.textDidBeginEditing
            .bind(with: self) { s, _ in
                s.navigationItem.largeTitleDisplayMode = .never
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .bind(with: self) { s, _ in
                s.navigationController?.navigationBar.prefersLargeTitles = false
            }
            .disposed(by: disposeBag)
        
        output.searchedError
            .bind(with: self) { vc, error in
                if let error = error as? ItunesNetworkError {
                    print(error.errorString)
                }
            }
            .disposed(by: disposeBag)
        
        output.searchedItemList
            .bind(with: self) { vc, results in
                dump(results)
            }
            .disposed(by: disposeBag)
    }
}
