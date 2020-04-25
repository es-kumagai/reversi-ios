//
//  Players.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

struct Players {
    
    var darkSide: Player
    var lightSide: Player
}

extension Players {
    
    subscript(of side: Disk) -> Player {
        
        get {
            
            switch side {
                
            case .dark:
                return darkSide
                
            case .light:
                return lightSide
            }
        }
        
        set (player) {
            
            switch side {
                
            case .dark:
                darkSide = player
                
            case .light:
                lightSide = player
            }
        }
    }
}
