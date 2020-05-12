//
//  GameControllerDelegate.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

@objc protocol GameControllerDelegate : class {
    
    func gameController(_ controller: GameController, thinkingWillStartBySide side: Disk)
    func gameController(_ controller: GameController, thinkingDidEndBySide side: Disk)
    func gameController(_ controller: GameController, turnChanged side: Disk)
    func gameController(_ controller: GameController, cannotMoveAnyware side: Disk)
    func gameController(_ controller: GameController, gameOverWithWinner record: GameRecord, board: Board)
    func gameController(_ controller: GameController, gameDidStartWithBoard board: Board, turn: Disk, players: Players)
    func gameController(_ controller: GameController, setSquare state: Square.State, location: Location, animationDuration duration: Double)
    func gameController(_ controller: GameController, boardChanged board: Board, moves: [Location], animationDuration duration: Double)
}
