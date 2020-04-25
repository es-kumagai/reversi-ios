//
//  Board.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

struct Board {
    
    let cols: Int
    let rows: Int
    
    private(set) var squares: [Square]
    
    init(cols: Int, rows: Int) {
        
        self.cols = cols
        self.rows = rows
        
        squares = []
        
        for row in 0 ..< rows {
            
            for col in 0 ..< cols {
                
                squares.append(Square(location: Location(col: col, row: row)))
            }
        }
    }
}

private extension Board {
    
    func squareIndex(of location: Location) -> Int {
        
        return location.row * rows + location.col
    }
}

extension Board {
    
    /// 盤上の升目の数です。
    var squareCount: Int {
        
        return cols * rows
    }
    
    /// 盤上の全ての升目を列単位で取得します。
    var squaresPerRow: [[Square]] {
        
        var result: [[Square]] = []
        
        for row in 0 ..< rows {
            
            let squaresAtRow = squares.filter { $0.location.row == row }
            
            result.append(squaresAtRow)
        }
        
        return result
    }
    
    /// `location` で指定された升目に `disk` を設定します。
    /// - Parameter disk: セルに設定される新しい状態です。 `nil` はディスクが置かれていない状態を表します。
    /// - Parameter location: セルの位置です。
    subscript(_ location: Location) -> Disk? {
        
        get {
            
            return squares[squareIndex(of: location)].disk
        }
        
        set (disk) {

            squares[squareIndex(of: location)].disk = disk
        }
    }
    
    /// 盤をゲーム開始時に状態に戻します。
    mutating func reset() {
        
        for square in squares {
            
            self[square.location] = nil
        }
        
        self[Location(col: cols / 2 - 1, row: rows / 2 - 1)] = .light
        self[Location(col: cols / 2, row: rows / 2 - 1)] = .dark
        self[Location(col: cols / 2 - 1, row: rows / 2)] = .dark
        self[Location(col: cols / 2, row: rows / 2)] = .light
    }
    
    /// `location` が盤上に収まるかを調べます。
    /// - Parameter location: 盤の位置
    /// - Returns: おさまる場合に `true` そうでない場合は `false`
    func contains(_ location: Location) -> Bool {
        
        return contains(col: location.col) && contains(row: location.row)
    }
    
    /// `col` が盤面の列内に収まるかを調べます。
    /// - Parameter col: 盤の列位置
    /// - Returns: おさまる場合に `true` そうでない場合は `false`
    func contains(col: Int) -> Bool {
        
        return (0 ..< cols).contains(col)
    }
    
    /// `row`
    /// - Parameter row: 盤の行位置
    /// - Returns: おさまる場合に `true` そうでない場合は `false`
    func contains(row: Int) -> Bool {
        
        return (0 ..< rows).contains(row)
    }
}
