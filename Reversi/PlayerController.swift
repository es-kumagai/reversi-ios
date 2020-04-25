//
//  PlayerController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

class PlayerController: NSObject {
    
    @IBOutlet private var gameController: GameController!

    private(set) var players: Players = Players(darkSide: .manual, lightSide: .manual)
    
    func changePlayer(of side: Disk, to player: Player) {
        
        players[of: side] = player
    }
}
