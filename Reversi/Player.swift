//
//  Player.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

//protocol Player {
//    
//    func abortThinking()
//}

enum Player: Int {
    
    case manual = 0
    case computer = 1
}

extension Player {
    
    /// 次の１手を返します。
    /// - Returns: マニュアルの場合に nil を返します。
    func ponderNextMove(handler: (Location?) -> Void) {
        
        
    }
}
