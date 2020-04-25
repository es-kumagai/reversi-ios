//
//  GameController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

class GameController : NSObject {
    
    private(set) var board = Board(cols: 8, rows: 8)
    
    /// 試合中でどちらの色のプレイヤーのターンかを `.playing` で表します。ゲーム終了時は `.over` です。
    private(set) var state: GameState = .over
    
    /// アニメーションの待ち時間を指定します。
    private var animationDuration = 0.3
    weak var delegate: GameControllerDelegate?

    @IBOutlet private var playerController: PlayerController!
    
    private var playerCancellers: [Disk: Canceller] = [:]
    
    
    /// どちらの色のプレイヤーのターンかを表します。ゲーム終了時は `nil` です。
    var turn: Disk? {
    
        switch state {
            
        case .playing(side: let side):
            return side
            
        case .over:
            return nil
        }
    }
    
    /// 試合中であれば `true` を返し、そうでない場合は `false` を返します。
    var isPlaying: Bool {
        
        switch state {
            
        case .playing:
            return true
            
        case .over:
            return false
        }
    }
    
    func newGame() {
        
        delegate?.gameController(self, gameWillStart: ())
        
        for side in Disk.sides {
            playerCancellers[side]?.cancel()
            playerCancellers.removeValue(forKey: side)
        }
        
        state = .playing(side: .dark)
        board.reset()

        delegate?.gameController(self, gameDidStartWithBoard: board)
    }
    
    func changePlayer(_ player: Player, of side: Disk) {
        
        if let canceller = playerCancellers[side] {
            canceller.cancel()
        }
        
        if side == turn, case .computer = player {
            playTurnOfComputer()
        }
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
    /// - Parameter animationDuration: アニメーション表示時の待ち時間です。
    func set(_ disk: Disk?, at location: Location, animationDuration duration: Double) {
        
        guard board.contains(location) else {
            
            fatalError("Location Out of Range: \(location)")
        }
        
        guard board[location] != disk else {
            
            return
        }

        board[location] = disk
        
        delegate?.gameController(self, setDisk: disk, location: location, animationDuration: duration)
    }
    
    /// 盤上に置かれたディスクの枚数が多い方の色を返します。
    /// 引き分けの場合は `nil` が返されます。
    /// - Returns: 盤上に置かれたディスクの枚数が多い方の色です。引き分けの場合は `nil` を返します。
    func dominantSide() -> Disk? {
        
        let darkCount = diskCount(of: .dark)
        let lightCount = diskCount(of: .light)

        if darkCount == lightCount {
            return nil
        } else {
            return darkCount > lightCount ? .dark : .light
        }
    }
    
    /// `side` で指定された色のディスクが盤上に置かれている枚数を返します。
    /// - Parameter side: 数えるディスクの色です。
    /// - Returns: `side` で指定された色のディスクの、盤上の枚数です。
    func diskCount(of side: Disk) -> Int {
        
        return board.count(of: side)
    }
}

extension GameController {
    
    /// "Computer" が選択されている場合のプレイヤーの行動を決定します。
    func playTurnOfComputer() {
        guard let turn = turn else { preconditionFailure() }
        
        delegate?.gameController(self, ponderingWillStartBySide: turn)
        
        let location = validMoves(for: turn).randomElement()!
        
        let cleanUp: () -> Void = { [weak self] in
            guard let self = self else { return }
            
            self.playerCancellers[turn] = nil

            self.delegate?.gameController(self, ponderingDidEndBySide: turn)
        }
        let canceller = Canceller(cleanUp)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            if canceller.isCancelled { return }
            cleanUp()
            
            do {
                
                try self.placeDisk(turn, at: location, animated: true)
                self.nextTurn()
            }
            catch _ {
                
            }
        }
        
        playerCancellers[turn] = canceller
    }
}

extension GameController {
    
    enum FileIOError: Error {
        case write(path: String, cause: Error?)
        case read(path: String, cause: Error?)
    }

    private var path: String {
        (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("Game")
    }
    
    /// ゲームの状態をファイルに書き出し、保存します。
    func saveGame() throws {
        var output: String = ""
        output += state.description
        for side in Disk.sides {
            
            let player = playerController.players[of: side]
            output += player.rawValue.description
        }
        output += "\n"
        
        for squaresPerRow in board.squaresPerRow {
            for square in squaresPerRow {
                output += square.disk?.description ?? "-"
            }
            output += "\n"
        }
        
        do {
            try output.write(toFile: path, atomically: true, encoding: .utf8)
        } catch let error {
            throw FileIOError.read(path: path, cause: error)
        }
    }

    /// ゲームの状態をファイルから読み込み、復元します。
    func loadGame() throws {
        let input = try String(contentsOfFile: path, encoding: .utf8)
        var lines: ArraySlice<Substring> = input.split(separator: "\n")[...]
        
        guard var line = lines.popFirst() else {
            throw FileIOError.read(path: path, cause: nil)
        }
        
        do { // turn
            guard
                let stateDescription = line.popFirst(),
                let state = GameState(description: String(stateDescription))
                else {
                    throw FileIOError.read(path: path, cause: nil)
            }
            self.state = state
        }
        
        // players
        for side in Disk.sides {
            guard
                let playerSymbol = line.popFirst(),
                let playerNumber = Int(playerSymbol.description),
                let player = Player(rawValue: playerNumber)
                else {
                    throw FileIOError.read(path: path, cause: nil)
            }
            
            playerController.changePlayer(of: side, to: player)
        }
        
        do { // board
            guard lines.count == board.rows else {
                throw FileIOError.read(path: path, cause: nil)
            }
            
            delegate?.gameController(self, gameWillStart: ())

            var row = 0
            while let line = lines.popFirst() {
                var col = 0
                for character in line {
                    let disk = Disk(description: "\(character)")
                    set(disk, at: Location(col: col, row: row), animationDuration: 0)
                    col += 1
                }
                guard col == board.cols else {
                    throw FileIOError.read(path: path, cause: nil)
                }
                row += 1
            }
            guard row == board.rows else {
                throw FileIOError.read(path: path, cause: nil)
            }

            delegate?.gameController(self, gameDidStartWithBoard: board)
        }
    }

    /// `location` で指定されたセルに、 `disk` が置けるかを調べます。
    /// ディスクを置くためには、少なくとも 1 枚のディスクをひっくり返せる必要があります。
    /// - Parameter location: セルの位置です。
    /// - Returns: 指定されたセルに `disk` を置ける場合は `true` を、置けない場合は `false` を返します。
    func canPlaceDisk(_ disk: Disk, at location: Location) -> Bool {
        !flipLocationsBy(disk, at: location).isEmpty
    }
    
    /// `side` で指定された色のディスクを置ける盤上のセルの座標をすべて返します。
    /// - Returns: `side` で指定された色のディスクを置ける盤上のすべてのセルの座標の配列です。
    func validMoves(for side: Disk) -> [Location] {
        var locations: [Location] = []
        
        for square in board.squares {
            if canPlaceDisk(side, at: square.location) {
                locations.append(square.location)
            }
        }
        
        return locations
    }
    
    /// `side` で指定した側のプレイヤーを取得します。
    /// - Parameter side: 対象のディスクの色を指定します。
    /// - Returns: 該当するプレイヤーを取得します。
    func player(of side: Disk) -> Player {
        
        return playerController.players[of: side]
    }
    
    /// プレイヤーの行動後、そのプレイヤーのターンを終了して次のターンを開始します。
    /// もし、次のプレイヤーに有効な手が存在しない場合、パスとなります。
    /// 両プレイヤーに有効な手がない場合、ゲームの勝敗を表示します。
    func nextTurn() {
        guard var turn = turn else { return }
        
        turn.flip()
        
        if validMoves(for: turn).isEmpty {
            if validMoves(for: turn.flipped).isEmpty {
                
                state = .over
                delegate?.gameController(self, gameOverWithWinner: dominantSide())
            }
            else {

                state = .playing(side: turn)
                delegate?.gameController(self, turnChangedButCannotMoveAnyware: turn)
            }
        }
        else {
            
            state = .playing(side: turn)
            delegate?.gameController(self, turnChanged: turn)
        }
    }
    
    /// `location` で指定されたセルに `disk` を置きます。
    /// - Parameter location: セルの位置です。
    /// - Parameter isAnimated: ディスクを置いたりひっくり返したりするアニメーションを表示するかどうかを指定します。
    /// - Parameter completion: アニメーション完了時に実行されるクロージャです。
    ///     このクロージャは値を返さず、アニメーションが完了したかを示す真偽値を受け取ります。
    ///     もし `animated` が `false` の場合、このクロージャは次の run loop サイクルの初めに実行されます。
    /// - Throws: もし `disk` を `location` で指定されるセルに置けない場合、 `DiskPlacementError` を `throw` します。
    func placeDisk(_ disk: Disk, at location: Location, animated isAnimated: Bool) throws {
        
        let flipLocations = flipLocationsBy(disk, at: location)

        guard !flipLocations.isEmpty else {
            throw DiskPlacementError(disk: disk, location: location)
        }
        
        let locations = [location] + flipLocations
        let duration = isAnimated ? animationDuration : 0

        for location in locations {

            set(disk, at: location, animationDuration: duration)
        }
        
        try? saveGame()
    }
}

private extension GameController {
    
    func flipLocationsBy(_ disk: Disk, at location: Location) -> [Location] {
        
        guard self.disk(at: location) == nil else {
            return []
        }
        
        var diskLocations: [Location] = []
        
        for direction in Direction.allDirections {
            
            var location = location
            var diskLocationsInLine: [Location] = []
            
            flipping: while true {
                
                location = location.next(to: direction)
                
                guard board.contains(location) else {
                    
                    break flipping
                }
                
                switch (disk, self.disk(at: location)) { // Uses tuples to make patterns exhaustive
                case (.dark, .dark), (.light, .light):
                    diskLocations.append(contentsOf: diskLocationsInLine)
                    break flipping
                case (.dark, .light), (.light, .dark):
                    diskLocationsInLine.append(location)
                case (_, .none):
                    break flipping
                }
            }
        }
        
        return diskLocations
    }
}

// MARK: Additional types

final class Canceller {
    private(set) var isCancelled: Bool = false
    private let body: (() -> Void)?
    
    init(_ body: (() -> Void)?) {
        self.body = body
    }
    
    func cancel() {
        if isCancelled { return }
        isCancelled = true
        body?()
    }
}

struct DiskPlacementError: Error {
    let disk: Disk
    let location: Location
}

