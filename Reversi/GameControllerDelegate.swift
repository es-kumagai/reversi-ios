//
//  GameControllerDelegate.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

protocol GameControllerDelegate : class {
    
    func gameController(_ controller: GameController, ponderingWillStartBySide side: Disk)
    func gameController(_ controller: GameController, ponderingDidEndBySide side: Disk)
    func gameController(_ controller: GameController, turnChanged side: Disk)
    func gameController(_ controller: GameController, turnChangedButCannotMoveAnyware side: Disk)
    func gameController(_ controller: GameController, gameOverWithWinner side: Disk?)
    func gameController(_ controller: GameController, gameWillStart _: Void)
    func gameController(_ controller: GameController, gameDidStartWithBoard board: Board)
    func gameController(_ controller: GameController, setDisk disk: Disk?, location: Location, animationDuration duration: Double)
}
