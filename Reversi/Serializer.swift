//
//  Serializer.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/27.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

@_functionBuilder
enum Serialization {
    
    static func buildBlock(_ turn: TurnState, _ players: Players, _ board: Board) -> String {
        
        return Serializer.serialization(turn: turn, players: players, board: board)
    }
}

@_functionBuilder
private enum MultilineString {
    
    static func buildBlock(_ strings: String ...) -> String {
        
        return strings.joined(separator: "\n") + "\n"
    }
}

enum Serializer {
    
    @MultilineString
    static func serialization(turn: TurnState, players: Players, board: Board) -> String {
        
        serialization(turn: turn) + serialization(players: players)
        serialization(board: board)
    }
}

private extension Serializer {
    
    static func serialization(turn: TurnState) -> String {
        
        return turn.description
    }
    
    static func serialization(players: Players) -> String {
        
        return Disk.sides.reduce("") { result, side in
            
            return result + players[of: side].rawValue.description
        }
    }
    
    static func serialization(square: Square) -> String {
        
        return square.state.description
    }

    static func serialization(board: Board) -> String {
        
        return board.squaresPerRow.map { squares in
            
            squares.reduce("") { serializedRow, square in
                
                serializedRow + serialization(square: square)
            }
        }
        .joined(separator: "\n")
    }
}
