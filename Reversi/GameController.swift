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
    static let GameControllerGameWillStart = Notification.Name("GameControllerGameWillStart")
    static let GameControllerGameDidStart = Notification.Name("GameControllerGameDidStart")
    static let GameControllerDiskSet = Notification.Name("GameControllerDiskSet")
}

class GameController : NSObject {
    
    private(set) var gameNumber = 0
    private let notificationCenter = NotificationCenter.default
    
    private(set) var board = Board(cols: 8, rows: 8)
    
    public func newGame() {
        
        gameNumber += 1

        notificationCenter.post(name: .GameControllerNewGame, object: self, userInfo: ["gameNumber" : gameNumber])
        notificationCenter.post(name: .GameControllerGameWillStart, object: self, userInfo: ["gameNumber" : gameNumber])
        
        board.reset()

        notificationCenter.post(name: .GameControllerGameDidStart, object: self, userInfo: ["gameNumber" : gameNumber])
    }
    
    /// `location` で指定された升目の `disk` を参照します。
    /// - Parameter disk: 升目のディスクです。 `nil` はディスクが置かれていない状態を表します。
    /// - Parameter location: セルの位置です。
    func disk(at location: Location) -> Disk? {
        
        guard board.contains(location) else {
            
            fatalError("Location Out of Range: \(location)")
        }
        
        return board[location]
    }
    
    /// `location` で指定された升目に `disk` を設定します。
    /// - Parameter disk: 升目に設定される新しい状態です。 `nil` はディスクが置かれていない状態を表します。
    /// - Parameter location: セルの位置です。
    func set(_ disk: Disk?, at location: Location) {
        
        guard board.contains(location) else {
            
            fatalError("Location Out of Range: \(location)")
        }
        
        guard board[location] != disk else {
            
            return
        }

        board[location] = disk
        
        NotificationCenter.default.post(name: .GameControllerDiskSet, object: self, userInfo: [
            "disk" : disk as Any,
            "location" : location,
            "gameNumber" : gameNumber
        ])
    }
}
