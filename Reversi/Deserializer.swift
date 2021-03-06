//
//  Deserializer.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/27.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// 直列化を解消する役割を担う型です。
enum Deserializer {
    
    /// 指定された文字列から直列化を解消してインスタンスを取得します。
    /// - Parameter string: 直列化された文字列です。
    /// - Throws: 直列化の解消に失敗した場合 `SerializationError.deserializaitonFailure` を発生します。
    /// - Returns: 取り出されたインスタンスです。
    static func deserialization(_ string: String) throws -> (turn: TurnState, players: (darkSide: PlayerMode, lightSide: PlayerMode), board: Board) {
        
        let components = try self.components(from: string)
        
        let turn = try deserialization(turn: components.turn)
        let players = try deserialization(players: components.players)
        let board = try deserialization(board: components.board)
        
        return (turn, players, board)
    }
}

private extension Deserializer {
    
    /// 直列化された文字列を、要素毎に分離します。
    /// - Parameter string: 直列化された文字列です。
    /// - Throws: 直列化の解消に失敗した場合 `SerializationError.deserializaitonFailure` を発生します。
    /// - Returns: 要素毎の文字列表現を返します。
    static func components(from string: String) throws -> (turn: String, players: String, board: [String]) {
        
        let components = string.split(separator: "\n")

        guard let turnAndPlayersComponent = components.first else {
         
            throw SerializationError.deserializationFailure("Invalid serialized string: \(string).")
        }
       
        let turn = String(turnAndPlayersComponent.prefix(1))
        let players = String(turnAndPlayersComponent.suffix(from: turnAndPlayersComponent.index(after: turnAndPlayersComponent.startIndex)))
        let board = components.suffix(from: 1).map(String.init)
        
        return (turn, players, board)
    }
    
    /// ターン情報を文字列からインスタンスに復元します。
    /// - Parameter string: 文字列化されたターン情報です。
    /// - Throws: 失敗した場合 `SerializationError.deserializaitonFailure` を発生します。
    /// - Returns: 復元されたインスタンスです。
    static func deserialization(turn string: String) throws -> TurnState {
        
        guard let result = TurnState(description: String(string)) else {
            
            throw SerializationError.deserializationFailure("Invalid serialized turn string: \(string)")
        }
        
        return result
    }
    
    /// プレイヤーの動作モード情報を文字列からインスタンスに復元します。
    /// - Parameter string: 文字列化された動作モード情報です。
    /// - Throws: 失敗した場合 `SerializationError.deserializaitonFailure` を発生します。
    /// - Returns: 復元されたインスタンスです。
    static func deserialization(players string: String) throws -> (darkSide: PlayerMode, lightSide: PlayerMode) {
        
        guard string.count == Disk.sides.count else {
            
            throw SerializationError.deserializationFailure("Invalid serialized players string: \(string)")
        }
        
        let players = try zip(Disk.sides, string).map { (side, symbol) -> PlayerMode in

            guard let symbolNumber = Int(symbol.description), let player = PlayerMode(rawValue: symbolNumber) else {
                
                throw SerializationError.deserializationFailure("Invalid serialized player symbol: \(symbol)")
            }
            
            return player
        }
        
        return (darkSide: players[0], lightSide: players[1])
    }
    
    /// 盤面情報を文字列からインスタンスに復元します。
    /// - Parameter string: 文字列化された盤面情報です。
    /// - Throws: 失敗した場合 `SerializationError.deserializaitonFailure` を発生します。
    /// - Returns: 復元されたインスタンスです。
    static func deserialization(board strings: [String]) throws -> Board {
        
        var result = Board(cols: 8, rows: 8)
        
        guard strings.count == result.rows else {
            
            throw SerializationError.deserializationFailure("Invalid serialized board: \(strings)")
        }
        
        for (row, string) in strings.enumerated() {
            
            let squaresPerRow = try string.map { (symbol) -> Square.State in
                
                guard let square = Square.State(description: String(symbol)) else {
                    
                    throw SerializationError.deserializationFailure("Invalid serialized square: \(symbol)")
                }
                
                return square
            }
            
            guard squaresPerRow.count == result.cols else {
                
                throw SerializationError.deserializationFailure("Invalid serialized board's column: \(string)")
            }
            
            for (col, square) in squaresPerRow.enumerated() {
                
                result[Location(col: col, row: row)] = square
            }
        }
        
        return result
    }
}
