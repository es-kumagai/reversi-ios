import UIKit

extension Notification.Name {
    
    static let ViewControllerReset = Notification.Name(rawValue: "ViewControllerReset")
}

class ViewController: UIViewController {
    
    @IBOutlet private var viewUpdateController: ViewUpdateController!
    @IBOutlet private var gameController: GameController!
    
    @IBOutlet private var boardView: BoardView!
    
    @IBOutlet private var messageDiskView: DiskView!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var messageDiskSizeConstraint: NSLayoutConstraint!
    
    /// Storyboard 上で設定されたサイズを保管します。
    /// 引き分けの際は `messageDiskView` の表示が必要ないため、
    /// `messageDiskSizeConstraint.constant` を `0` に設定します。
    /// その後、新しいゲームが開始されたときに `messageDiskSize` を
    /// 元のサイズで表示する必要があり、
    /// その際に `messageDiskSize` に保管された値を使います。
    private var messageDiskSize: CGFloat!
    
    @IBOutlet private var playerControls: [UISegmentedControl]!
    @IBOutlet private var countLabels: [UILabel]!
    @IBOutlet private var playerActivityIndicators: [UIActivityIndicatorView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageDiskSize = messageDiskSizeConstraint.constant
        
        do {
            
            try gameController.loadGame()
        }
        catch _ {
            
            gameController.newGame()
        }
    }
    
    private var viewHasAppeared: Bool = false
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewHasAppeared { return }
        viewHasAppeared = true
        
        gameController.startGame()
    }
}

// MARK: Views

extension ViewController : ViewUpdateControllerDelegate {
    
    func viewUpdateController(_ controller: ViewUpdateController, updateSquare state: Square.State, location: Location, animated: Bool) {
        
        boardView.set(square: state, location: location, animated: true)
    }
    
    func viewUpdateController(_ controller: ViewUpdateController, updateBoard board: Board, animated: Bool) {
        
        boardView.set(board: board, animated: true)
    }
}

extension ViewController {
    
    /// 盤面を一括で更新します。
    func updateBoard(_ board: Board) {
        
        viewUpdateController.request(.board(board: board))
    }
    
    /// 各プレイヤーの獲得したディスクの枚数を表示します。
    func updateCountLabels(of board: Board) {
        
        for side in Disk.sides {
            
            countLabels[segmentIndex(of: side)].text = "\(board.count(of: side))"
        }
    }
    
    /// 勝敗を表示します。
    func updateTurnMessage(winner side: Disk?) {
        
        switch side {
            
        case .some(let winner):
            messageDiskSizeConstraint.constant = messageDiskSize
            messageDiskView.disk = winner
            messageLabel.text = " won"
            
        case .none:
            messageDiskSizeConstraint.constant = 0
            messageLabel.text = "Tied"
        }
    }
    
    /// 現在のターン情報を表示します。
    func updateTurnMessage(turn side: Disk) {
        
        messageDiskSizeConstraint.constant = messageDiskSize
        messageDiskView.disk = side
        messageLabel.text = "'s turn"
    }

}

// MARK: Inputs

extension ViewController {
    
    /// リセットボタンが押された場合に呼ばれるハンドラーです。
    /// アラートを表示して、ゲームを初期化して良いか確認し、
    /// "OK" が選択された場合ゲームを初期化します。
    @IBAction func pressResetButton(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: "Confirmation",
            message: "Do you really want to reset the game?",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] _ in

            self.gameController.newGame()
            self.gameController.startGame()
            
            NotificationCenter.default.post(name: .ViewControllerReset, object: self)
        })
        present(alertController, animated: true)
    }
    
    /// プレイヤーのモードが変更された場合に呼ばれるハンドラーです。
    @IBAction func changePlayerControlSegment(_ sender: UISegmentedControl) {

        let side: Disk = self.side(of: sender)
        let mode = PlayerMode(rawValue: sender.selectedSegmentIndex)!
        
        gameController.changePlayerMode(mode, of: side)
    }
}

extension ViewController: BoardViewDelegate {
    /// `boardView` の `location` で指定されるセルがタップされたときに呼ばれます。
    /// - Parameter boardView: セルをタップされた `BoardView` インスタンスです。
    /// - Parameter location: セルの位置です。
    func boardView(_ boardView: BoardView, didSelectCellAt location: Location) {

        // try? because doing nothing when an error occurs
        do {
            
            try gameController.select(location, animated: true, switchToNextTurn: true)
        }
        catch _ {
            
        }
    }
}

// MARK: File-private extensions

private extension ViewController {
    
    func segmentIndex(of side: Disk) -> Int {
        
        return side.rawValue
    }
    
    func side(of segmentControl: UISegmentedControl) -> Disk {

        let index = playerControls.firstIndex(of: segmentControl)!

        guard let side = Disk(rawValue: index) else {
            
            fatalError("Invalid index: \(index)")
        }
        
        return side
    }
}

extension ViewController : GameControllerDelegate {
    
    func gameController(_ controller: GameController, gameDidStartWithBoard board: Board, turn side: Disk, players: Players) {

        viewUpdateController.resetRequests()
        updateBoard(board)
        updateCountLabels(of: board)
        updateTurnMessage(turn: side)
        
        for side in Disk.sides {
            
            playerControls[segmentIndex(of: side)].selectedSegmentIndex = players[of: side].type.rawValue
        }
    }
    
    func gameController(_ controller: GameController, setSquare state: Square.State, location: Location, animationDuration duration: Double) {

        viewUpdateController.request(.square(state: state, location: location))
        viewUpdateController.request(.sleep(interval: duration))
    }
    
    func gameController(_ controller: GameController, boardChanged board: Board, moves: [Location], animationDuration duration: Double) {
        
        for side in Disk.sides {
            
            countLabels[segmentIndex(of: side)].text = "\(board.count(of: side))"
        }
    }

    func gameController(_ controller: GameController, thinkingWillStartBySide side: Disk, player: Player) {
        
        if player.type == .computer {

            playerActivityIndicators[segmentIndex(of: side)].startAnimating()
        }
    }
    
    func gameController(_ controller: GameController, thinkingDidEndBySide side: Disk, player: Player) {
        
        playerActivityIndicators[segmentIndex(of: side)].stopAnimating()
    }
    
    func gameController(_ controller: GameController, turnChanged side: Disk) {
        
        updateTurnMessage(turn: side)
    }
    
    func gameController(_ controller: GameController, cannotMoveAnyware side: Disk) {
        
        let alertController = UIAlertController(
            title: "Pass",
            message: "Cannot place a disk.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { _ in
            controller.nextTurn(withReason: .passed)
        })
        
        present(alertController, animated: true)
    }
    
    func gameController(_ controller: GameController, gameOverWithWinner record: GameRecord, board: Board) {
        
        updateBoard(board)
        updateCountLabels(of: board)
        updateTurnMessage(winner: record.winner)
    }
}
