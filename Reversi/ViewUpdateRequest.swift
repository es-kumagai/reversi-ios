//
//  DiskChangeRequest.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

enum ViewUpdateRequest {
    

    case square(gameNumber: Int, disk: Disk?, location: Location)
    case board(gameNumber: Int, board: Board)
}

extension Queue where Element == ViewUpdateRequest {
    
    /// `forGameNumber` で指定したゲーム用のリクエストを取得します。
    /// それ以外のゲーム用のリクエストは捨てられます。
    /// - Parameter number: 目的のゲーム番号です。
    /// - Returns: 指定されたゲーム用の最初に見つかったリクエストです。
    mutating func dequeue(forGameNumber gameNumber: Int) -> Element? {
    
        while let element = dequeue() {
            
            switch element {
                
            case .square(gameNumber: gameNumber, disk: _, location: _),
                 .board(gameNumber: gameNumber, _):
                return element
                
            default:
                continue
            }
        }
        
        return nil
    }
}
