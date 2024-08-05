//
//  Enum+Validation.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/5/24.
//

import UIKit

enum ValidationColor {
    case error
    case valid
    
    var byColor: UIColor {
        switch self {
        case .error:
            return .systemRed
        case .valid:
            return .systemBlue
        }
    }
}
