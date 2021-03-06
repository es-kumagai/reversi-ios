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
    @IBOutlet private var turnController: TurnController!
    
    @IBOutlet var delegate: PlayerControllerDelegate?

    private(set) var players: Players!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        let darkSidePlayer = ManualPlayer(withDelegate: self)
        let lightSidePlayer = ManualPlayer(withDelegate: self)
        
        players = Players(darkSide: darkSidePlayer, lightSide: lightSidePlayer)
    }
    
    func changePlayerMode(of side: Disk, to mode: PlayerMode) {
        
        players[of: side].stopThinking()

        switch mode {
            
        case .manual:
            players[of: side] = ManualPlayer(withDelegate: self)

        case .computer:
            players[of: side] = ComputerPlayer(withDelegate: self)
        }
    }
    
    func side(of player: Player) -> Disk? {
        
        switch ObjectIdentifier(player) {

        case ObjectIdentifier(players.darkSide):
            return .dark
            
        case ObjectIdentifier(players.lightSide):
            return .light
            
        default:
            return nil
        }
    }

    func startThinking() {
        
        guard let turn = turnController.currentTurn else {
        
            return
        }
        
        let player = players[of: turn]
        
        player.startThinking(withSide: turn, board: gameController.board)
    }
}

extension PlayerController : PlayerDelegate {

    func playerThinkingWillStartByItself(_ player: Player) {

        guard let side = self.side(of: player) else {
            
            return
        }
        
        delegate?.playerController(self, thinkingWillStartBySide: side, player: player)
    }
    
    func player(_ player: Player, thinkingDidEndByItself thought: PlayerThought) {

        guard let side = self.side(of: player) else {
            
            return
        }
        
        delegate?.playerController(self, thinkingDidEndBySide: side, player: player, thought: thought)
    }
}
