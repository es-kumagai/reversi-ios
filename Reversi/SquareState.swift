//
//  SquareState.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/26.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

extension Square {
    
    /// 升目の状態です。
    /// dark: 黒のディスクが置かれている
    /// light: 白のディスクが置かれている
    /// empty: ディスクが置かれていない
    @objc enum State : Int {
        
        case dark = 0
        case light = 1
        case empty = -1
    }
}

extension Square.State {
    
    /// 升目のディスクの状態です。
    /// ディスクが置かれていない場合は `nil` です。
    var side: Disk? {
        
        switch self {
            
        case .dark:
            return .dark
            
        case .light:
            return .light
            
        case .empty:
            return nil
        }
    }
}

extension Square.State : CustomStringConvertible {
    
    /// ディスクの状態から升目の状態に変換します。
    /// - Parameter disk: ディスクの面です。`nil` の場合は「ディスクがない」ことを表現します。
    init(from disk: Disk?) {
        
        switch disk {
            
        case .dark:
            self = .dark
            
        case .light:
            self = .light
            
        case .none:
            self = .empty
        }
    }
    
    /// テキスト表現からの升目の状態を生成します。
    /// - Parameter description: <#description description#>
    init?(description: String) {
        
        switch description {
            
        case "x":
            self = .dark
            
        case "o":
            self = .light
            
        case "-":
            self = .empty
            
        default:
            return nil
        }
    }
    
    /// 升目の状態をテキストで表現します。
    var description: String {
        
        switch self {
            
        case .dark:
            return "x"
            
        case .light:
            return "o"
            
        case .empty:
            return "-"
        }
    }
}
