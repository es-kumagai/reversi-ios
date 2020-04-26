import UIKit

extension Notification.Name {
    
    static let ViewControllerReset = Notification.Name(rawValue: "ViewControllerReset")
}

class ViewController: UIViewController {
    
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
    
    private var viewUpdateProcessingQueue = DispatchQueue(label: "reversi.viewcontroller.animation")
    private var viewUpdateRequestQueue: Queue<ViewUpdateRequest> = []
    private var viewUpdateMessageLoopSource: DispatchSourceTimer!
    private var viewUpdateMessageLoopDuration = 0.005
    private var viewUpdateMessageLoopSleepCount = 0 as Double
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageDiskSize = messageDiskSizeConstraint.constant
        
        let source = DispatchSource.makeTimerSource(flags: [], queue: viewUpdateProcessingQueue)
        
        source.schedule(deadline: .now(), repeating: viewUpdateMessageLoopDuration)
        source.setEventHandler(handler: diskChangeRequestMessageLoop)

        viewUpdateMessageLoopSource = source
        viewUpdateMessageLoopSource.resume()
        
        do {
            try gameController.loadGame()
        } catch _ {
            gameController.newGame()
        }
    }
    
    private var viewHasAppeared: Bool = false
    
    func diskChangeRequestMessageLoop() {
        
        guard viewUpdateMessageLoopSleepCount == 0 else {
        
            viewUpdateMessageLoopSleepCount = max(viewUpdateMessageLoopSleepCount - 1, 0)
            return
        }
        
        guard let request = viewUpdateRequestQueue.dequeue() else {
            
            return
        }
        
        DispatchQueue.main.async {
            
            switch request {
                
            case .square(state: let state, location: let location):
                self.boardView.set(square: state, location: location, animated: true)
                
            case .board(board: let board):
                self.boardView.set(board: board, animated: true)
                
            case .sleep(interval: let interval):
                self.viewUpdateMessageLoopSleepCount = interval / self.viewUpdateMessageLoopDuration
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewHasAppeared { return }
        viewHasAppeared = true
        
        gameController.waitForPlayer(afterDelay: 0)
    }
}

// MARK: Views

extension ViewController {

    /// キューに溜まってる更新リクエストを消去します。
    func clearViewUpdateRequests() {
    
        viewUpdateProcessingQueue.async {
            
            self.viewUpdateRequestQueue.clear()
            self.viewUpdateMessageLoopSleepCount = 0
        }
    }
    
    /// 盤面を一括で更新します。
    func updateBoard(_ board: Board) {
        
        let request = ViewUpdateRequest.board(board: board)
        
        viewUpdateProcessingQueue.async {
            
            self.viewUpdateRequestQueue.enqueue(request)
        }
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
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
                        
            self.gameController.newGame()
            self.gameController.waitForPlayer(afterDelay: 0)
            
            NotificationCenter.default.post(name: .ViewControllerReset, object: self)
        })
        present(alertController, animated: true)
    }
    
    /// プレイヤーのモードが変更された場合に呼ばれるハンドラーです。
    @IBAction func changePlayerControlSegment(_ sender: UISegmentedControl) {

        let side: Disk = self.side(of: sender)
        let player = Player(rawValue: sender.selectedSegmentIndex)!
        
        gameController.changePlayer(player, of: side)        
    }
}

extension ViewController: BoardViewDelegate {
    /// `boardView` の `location` で指定されるセルがタップされたときに呼ばれます。
    /// - Parameter boardView: セルをタップされた `BoardView` インスタンスです。
    /// - Parameter location: セルの位置です。
    func boardView(_ boardView: BoardView, didSelectCellAt location: Location) {

        // try? because doing nothing when an error occurs
        do {
            
            try gameController.placeDisk(at: location, animated: true, switchToNextTurn: true)
        }
        catch _ {
            
        }
    }
}

// MARK: File-private extensions

private extension ViewController {
    
    func segmentIndex(of side: Disk) -> Int {
        
        switch side {
            
        case .dark:
            return 0
            
        case .light:
            return 1
        }
    }
    
    func side(of segmentControl: UISegmentedControl) -> Disk {
        
        let index = playerControls.firstIndex(of: segmentControl)!
        
        switch index {
            
        case 0:
            return .dark
            
        case 1:
            return .light
            
        default:
            fatalError("Invalid index: \(index)")
        }
    }
}

extension ViewController : GameControllerDelegate {
    
    func gameController(_ controller: GameController, gameDidStartWithBoard board: Board, turn side: Disk) {

        clearViewUpdateRequests()
        updateBoard(board)
        updateCountLabels(of: board)
        updateTurnMessage(turn: side)
    }
    
    func gameController(_ controller: GameController, setSquare state: SquareState, location: Location, animationDuration duration: Double) {

        viewUpdateProcessingQueue.async {
            
            self.viewUpdateRequestQueue.enqueue(.square(state: state, location: location))
            
            if duration != 0 {

                self.viewUpdateRequestQueue.enqueue(.sleep(interval: duration))
            }
        }
    }
    
    func gameController(_ controller: GameController, boardChanged board: Board, moves: [Location], animationDuration duration: Double) {
        
        for side in Disk.sides {
            
            countLabels[segmentIndex(of: side)].text = "\(controller.diskCount(of: side))"
        }
    }

    func gameController(_ controller: GameController, ponderingWillStartBySide side: Disk) {
        
        playerActivityIndicators[segmentIndex(of: side)].startAnimating()
    }
    
    func gameController(_ controller: GameController, ponderingDidEndBySide side: Disk) {
        
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
            controller.waitForPlayer(afterDelay: 0)
        })
        
        present(alertController, animated: true)
    }
    
    func gameController(_ controller: GameController, gameOverWithWinner record: GameRecord, board: Board) {
        
        updateCountLabels(of: board)
        updateTurnMessage(winner: record.winner)
    }
}
