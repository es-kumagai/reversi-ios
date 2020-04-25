//
//  GameState.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

enum GameState {
    
    case playing(side: Disk)
    case over
}

extension GameState : CustomStringConvertible {
    
    var description: String {
        
        switch self {
            
        case .playing(side: let side):
            return side.description
            
        case .over:
            return "-"
        }
    }
    
    init?(description: String) {
        
        if let side = Disk(description: description) {
            
            self = .playing(side: side)
        }
        else if description == "-" {
            
            self = .over
        }
        else {
            
            return nil
        }
    }
}
