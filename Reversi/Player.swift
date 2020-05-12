//
//  Player.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/05/12.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

@objc protocol Player : class {
    
    var type: PlayerType { get }

    weak var delegate: PlayerDelegate? { get }

    func startThinking(withSide side: Disk, board: Board)
    func stopThinking()
    func select(location: Location)
    
    init(withDelegate delegate: PlayerDelegate?)
}
