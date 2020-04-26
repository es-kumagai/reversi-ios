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
    
        init?(description: String) {
            
            switch description {
                
            case "x":
                self = .playing(side: .dark)
                
            case "o":
                self = .playing(side: .light)
                
            case "-":
                self = .over
                
            default:
                return nil
            }
        }
        
        var description: String {
            
            switch self {
                
            case .playing(.dark):
                return "x"
                
            case .playing(.light):
                return "o"
                
            case .over:
                return "-"
            }
        }
    }
