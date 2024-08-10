//
//  TaskTestViewController.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/9/24.
//

import UIKit

final class TaskTestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        Task {
            let a = Task {
                let one = await someAsync()
                return one
            }
            
            let b = Task {
                let two = await someAsync2()
                let three = await someAsync3()
                
                return two + three
            }
            
            await print(a.value, b.value)
        }
        
    }
    
    private func someAsync() async -> Int {
        print("async한 함수 1")
        return 1
    }
    
    private func someAsync2() async -> Int {
        print("async한 함수 2")
        return 2
    }
    
    private func someAsync3() async -> Int {
        print("async한 함수 3")
        return 3
    }
    
    actor SomeActor {
        
    }
}
