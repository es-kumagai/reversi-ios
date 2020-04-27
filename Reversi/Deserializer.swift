//
//  Deserializer.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/27.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

enum Deserializer {
    
    static func deserialization(_ string: String) throws -> (turn: TurnState, players: Players, board: Board) {
        
        let components = try self.components(from: string)
        
        let turn = try deserialization(turn: components.turn)
        let players = try deserialization(players: components.players)
        let board = try deserialization(board: components.board)
        
        return (turn, players, board)
    }
}

private extension Deserializer {
    
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
    
    static func deserialization(turn string: String) throws -> TurnState {
        
        guard let result = TurnState(description: String(string)) else {
            
            throw SerializationError.deserializationFailure("Invalid serialized turn string: \(string)")
        }
        
        return result
    }
    
    static func deserialization(players string: String) throws -> Players {
        
        guard string.count == Disk.sides.count else {
            
            throw SerializationError.deserializationFailure("Invalid serialized players string: \(string)")
        }
        
        let players = try zip(Disk.sides, string).map { (side, symbol) -> Player in

            guard let symbolNumber = Int(symbol.description), let player = Player(rawValue: symbolNumber) else {
                
                throw SerializationError.deserializationFailure("Invalid serialized player symbol: \(symbol)")
            }
            
            return player
        }
        
        return Players(darkSide: players[0], lightSide: players[1])
    }
    
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
