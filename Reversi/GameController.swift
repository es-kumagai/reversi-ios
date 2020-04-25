//
//  GameController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let GameControllerNewGame = Notification.Name("GameControllerNewGame")
}

class GameController {
    
    private(set) var gameNumber = 0
    private let notificationCenter = NotificationCenter.default
    
    public func newGame() {
        
        gameNumber += 1
        
        notificationCenter.post(name: .GameControllerNewGame, object: self, userInfo: ["number" : gameNumber])
    }
}
