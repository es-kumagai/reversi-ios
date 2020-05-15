//
//  GameController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

class GameController : NSObject {
    
    /// ゲームの盤面です。
    private(set) var board = Board(cols: 8, rows: 8)
    
    /// 現在のターンでディスクを置いて良い状態であることを示します。アニメーションが終わる頃合いを待つのに使います。
    private(set) var allowPlacingOnThisTurn = true
    
    /// アニメーションの待ち時間を指定します。
    private var animationDuration = 0.3
    @IBOutlet weak var delegate: GameControllerDelegate?
    
    @IBOutlet private var playerController: PlayerController!
    @IBOutlet private var turnController: TurnController!
    @IBOutlet private var fileController: FileController!
    
    /// ゲームを開始します。
    func startGame() {
        
        allowPlacingOnThisTurn = true
        playerController.startThinking()
    }
    
    /// 新規ゲームを準備します。
    func newGame() {
        
        for side in Disk.sides {
            
            playerController.changePlayerMode(of: side, to: .manual)
        }
        
        turnController.turnReset(with: .dark)
        allowPlacingOnThisTurn = false
        
        board.reset()
        
        delegate?.gameController(self, gameDidStartWithBoard: board, turn: .dark, players: playerController.players)
    }
    
    /// プレイヤーもーどを変更します。
    /// - Parameters:
    ///   - mode: 変更後のモードです。
    ///   - side: 変更対象のプレイヤーを指定します。
    func changePlayerMode(_ mode: PlayerMode, of side: Disk) {
        
        playerController.changePlayerMode(of: side, to: mode)
        try? saveGame()
        
        playerController.startThinking()
    }
    
    /// `location` で指定された升目に `disk` を設定します。
    /// - Parameter state: 升目に設定される新しい状態です。
    /// - Parameter location: セルの位置です。
    /// - Parameter animationDuration: アニメーション表示時の待ち時間です。
    private func set(_ state: Square.State, at location: Location, animationDuration duration: Double) {
        
        guard board.contains(location) else {
            
            fatalError("Location Out of Range: \(location)")
        }
        
        guard board[location] != state else {
            
            return
        }
        
        board[location] = state
        
        delegate?.gameController(self, setSquare: state, location: location, animationDuration: duration)
    }
    
    /// 盤上に置かれたディスクの枚数が多い方の色を返します。
    /// 引き分けの場合は `nil` が返されます。
    /// - Returns: 盤上に置かれたディスクの枚数が多い方の色です。引き分けの場合は `nil` を返します。
    func dominantSide() -> Disk? {
        
        let darkCount = board.count(of: .dark)
        let lightCount = board.count(of: .light)
        
        if darkCount == lightCount {
            return nil
        } else {
            return darkCount > lightCount ? .dark : .light
        }
    }
}

extension GameController {
    
    /// ゲームの状態をファイルに書き出し、保存します。
    func saveGame() throws {
        
        try fileController.writeToFile {
            
            turnController.currentState     // Turn
            playerController.players!       // Players
            board                           // Board
        }
    }
    
    /// ゲームの状態をファイルから読み込み、復元します。
    func loadGame() throws {
        
        let input = try fileController.readFromFile()

        do {
            
            let deserialized = try Deserializer.deserialization(input)
            
            // Turn
            switch deserialized.turn {
                
                case .playing(side: let side):
                    turnController.turnChange(to: side, reason: .initial)
                    
                case .over:
                    turnController.turnReset()
            }
            
            // Players
            playerController.changePlayerMode(of: .dark, to: deserialized.players.darkSide)
            playerController.changePlayerMode(of: .light, to: deserialized.players.lightSide)

            // Board
            board = deserialized.board
        }
        catch {
        
            throw FileIOError.read(path: fileController.file, cause: error)
        }
        
        allowPlacingOnThisTurn = true
        
        if turnController.isGameOver {

            delegate?.gameController(self, gameOverWithWinner: GameRecord(winner: dominantSide()), board: board)
        }
        else {
            
            delegate?.gameController(self, gameDidStartWithBoard: board, turn: turnController.currentTurn!, players: playerController.players)
        }
    }
                
    /// `side` で指定した側のプレイヤーを取得します。
    /// - Parameter side: 対象のディスクの色を指定します。
    /// - Returns: 該当するプレイヤーを取得します。
    func player(of side: Disk) -> Player {
        
        return playerController.players[of: side]
    }
    
    /// プレイヤーの行動後、そのプレイヤーのターンを終了して次のターンを開始します。
    func nextTurn(withReason reason: TurnController.ChangedReason) {
        
        guard let newSide = turnController.currentTurn?.flipped else {
        
            return
        }
        
        turnController.turnChange(to: newSide, reason: reason)
        try? saveGame()

        if turnController.isGameOver {
            
            delegate?.gameController(self, gameOverWithWinner: GameRecord(winner: dominantSide()), board: board)
        }
        else {

            delegate?.gameController(self, turnChanged: newSide)
        }
    }
    
    /// `location` で指定されたセルに、現在のターンの置きます。
    /// - Parameter location: セルの位置です。
    /// - Parameter isAnimated: ディスクを置いたりひっくり返したりするアニメーションを表示するかどうかを指定します。
    /// - Throws: もし `disk` を `location` で指定されるセルに置けない場合、 `DiskPlacementError` を `throw` します。
    func select(_ location: Location, animated isAnimated: Bool, switchToNextTurn: Bool) throws {
        
        guard let turn = turnController.currentTurn else {
            
            return
        }
        
        let player = self.player(of: turn)
        
        guard player.type == .manual else {
            
            return
        }
        
        player.select(location: location)
    }
    
    /// `location` で指定されたセルに `disk` を置きます。
    /// - Parameter location: セルの位置です。
    /// - Parameter isAnimated: ディスクを置いたりひっくり返したりするアニメーションを表示するかどうかを指定します。
    /// - Throws: もし `disk` を `location` で指定されるセルに置けない場合、 `DiskPlacementError` を `throw` します。
    func place(_ disk: Disk, at location: Location, animated isAnimated: Bool, switchToNextTurn: Bool) throws {
        
        guard allowPlacingOnThisTurn else {
            
            return
        }
        
        let flipLocations = board.flipLocationsBy(disk, at: location)
        
        guard !flipLocations.isEmpty else {
            throw DiskPlacementError(disk: disk, location: location)
        }
        
        allowPlacingOnThisTurn = false

        let locations = [location] + flipLocations
        let duration = isAnimated ? animationDuration : 0
        
        for location in locations {
            
            set(Square.State(from: disk), at: location, animationDuration: duration)
        }
        
        try? saveGame()
        delegate?.gameController(self, boardChanged: board, moves: locations, animationDuration: duration)
        
        if switchToNextTurn {
            
            let delay = animationDuration * Double(locations.count)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                
                self.allowPlacingOnThisTurn = true
                self.playerController.startThinking()
            }
            
            nextTurn(withReason: .moved)
        }
        else {
            
            allowPlacingOnThisTurn = true
            playerController.startThinking()
        }
    }
}

extension GameController : PlayerControllerDelegate {
    
    func playerController(_ controller: PlayerController, thinkingWillStartBySide side: Disk, player: Player) {
        
        delegate?.gameController(self, thinkingWillStartBySide: side, player: player)
    }

    func playerController(_ controller: PlayerController, thinkingDidEndBySide side: Disk, player: Player, thought: PlayerThought) {

        delegate?.gameController(self, thinkingDidEndBySide: side, player: player)

        do {
            
            switch thought.state {
                
            case .specified(let location):
                if board.canPlaceDisk(side, at: location) {
                    fallthrough
                }
                
            case .moved(let location):
                try place(side, at: location, animated: true, switchToNextTurn: true)
                
            case .passed:
                
                if board.nextMoveAvailable(on: side.flipped) {
                    
                    delegate?.gameController(self, cannotMoveAnyware: side)
                }
                else {

                    nextTurn(withReason: .passed)
                    playerController.startThinking()
                }                

            case .aborted:
                break
            }
        }
        catch _ {
            
        }
    }
}
