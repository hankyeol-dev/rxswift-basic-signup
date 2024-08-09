//
//  MainTabbarController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit

class MainTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        bindTap()
    }

    private func bindTap() {
        let itunes = UINavigationController(rootViewController: ItunesViewController())
        itunes.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "apple.logo"), tag: 0)
        
        let shopping = UINavigationController(rootViewController: ShoppingListViewController())
        shopping.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "cart"), tag: 1)
        
        setViewControllers([itunes, shopping], animated: true)
        
        tabBar.backgroundColor = .white
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
    }
}

