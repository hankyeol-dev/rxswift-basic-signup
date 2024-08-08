//
//  Extension+UIViewController.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/2/24.
//

import UIKit

extension UIViewController {
    func validateEmail(for email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z._%-]+\\.[A-Za-z]{1,64}"
        return email.range(of: regex, options: .regularExpression) != nil
    }
    
    func dismissStack(for vc: UIViewController) {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = scene?.delegate as? SceneDelegate
        
        let window = sceneDelegate?.window
        
        window?.rootViewController = UINavigationController(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    
    func showTabbar() {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = scene?.delegate as? SceneDelegate
        
        let window = sceneDelegate?.window
        
        window?.rootViewController = MainTabbarController()
        window?.makeKeyAndVisible()
    }
}
