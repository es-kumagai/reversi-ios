//
//  DiskChangeRequest.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

enum ViewUpdateRequest {
    
    case square(state: Square.State, location: Location)
    case board(board: Board)
    case sleep(interval: Double)
}
