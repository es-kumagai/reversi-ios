//
//  TurnState.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

/// ターンの状態を表現する型です。
/// playing:    ゲーム中であることを示します。`side` には現在の手番の色が入ります。
/// over:       ゲームが終了していることを示します。
enum TurnState {
    
    case playing(side: Disk)
    case over
}

extension TurnState : CustomStringConvertible {
    
    /// テキスト表現からターンの状態を生成します。
    /// - Parameter description: ターンの状態を表現するテキストです。
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
    
    /// ターンの状態をテキストで表現します。
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
