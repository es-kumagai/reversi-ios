//
//  Player.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// プレイヤーの種類です。
@objc enum PlayerType: Int {

    case manual = 0
    case computer = 1
}

extension PlayerType : CustomStringConvertible {
    
    /// プレイヤーの種類をテキスト表現に変換します。
    var description: String {
        
        switch self {
            
        case .manual:
            return "manual"
            
        case .computer:
            return "computer"
        }
    }
}
