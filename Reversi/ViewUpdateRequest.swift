//
//  DiskChangeRequest.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

/// ビューの更新を要求する時に使う型です。
/// square: 升目の更新を要求します。更新後の升目の状態を `state` で指定します。対象の升目の位置を `location` で指定します。
/// board: 盤面の更新を要求します。更新後の盤面の状態を `board` で指定します。
/// sleep: `interval` で指定した時間、更新を停止することを要求します。
enum ViewUpdateRequest {
    
    case square(state: Square.State, location: Location)
    case board(board: Board)
    case sleep(interval: Double)
}
