//
//  DiskChangeRequest.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

struct ViewUpdateRequest {
    
    var disk: Disk?
    var location: Location
    var gameNumber: Int
}

extension Queue where Element == ViewUpdateRequest {
    
    /// `forGameNumber` で指定したゲーム用のリクエストを取得します。
    /// それ以外のゲーム用のリクエストは捨てられます。
    /// - Parameter number: 目的のゲーム番号です。
    /// - Returns: 指定されたゲーム用の最初に見つかったリクエストです。
    mutating func dequeue(forGameNumber number: Int) -> Element? {
    
        while let element = dequeue(), element.gameNumber == number {
            
            return element
        }
        
        return nil
    }
}
