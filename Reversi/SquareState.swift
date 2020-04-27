//
//  SquareState.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/26.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

extension Square {
    
    @objc enum State : Int {
        
        case dark = 0
        case light = 1
        case empty = -1
    }
}

extension Square.State {
 
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
