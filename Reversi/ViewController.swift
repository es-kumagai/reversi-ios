import UIKit

extension Notification.Name {
    
    static let ViewControllerReset = Notification.Name(rawValue: "ViewControllerReset")
}

class ViewController: UIViewController {
    
    @IBOutlet private var gameController: GameController! {
        
        didSet {
            
            gameController.delegate = self
        }
    }
    
    @IBOutlet private var boardView: BoardView! {
        
        didSet {
            
            boardView.delegate = self
        }
    }
    
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
    
    /// 新しいゲームを始める準備中に `true` になります。
    private var preparingForNewGame: Bool = false

    private var viewUpdateProcessingQueue = DispatchQueue(label: "reversi.viewcontroller.animation")
    private var viewUpdateRequestQueue: Queue<ViewUpdateRequest> = []
    private var viewUpdateMessageLoopSource: DispatchSourceTimer!
    private var viewUpdateMessageLoopDuration = 0.02
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
            newGame()
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
        
        // ゲーム開始の準備時はアニメーションを伴いません。
        let animated = !preparingForNewGame
        
        DispatchQueue.main.async {
            
            switch request {
                
            case .square(disk: let disk, location: let location):
                self.boardView.set(disk: disk, location: location, animated: animated)
                
            case .board(board: let board):
                self.boardView.set(board: board, animated: animated)
                
            case .sleep(interval: let interval):
                self.viewUpdateMessageLoopSleepCount = interval / self.viewUpdateMessageLoopDuration
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewHasAppeared { return }
        viewHasAppeared = true
        waitForPlayer()
    }
}

// MARK: Game management

extension ViewController {
    /// ゲームの状態を初期化し、新しいゲームを開始します。
    func newGame() {
        
        for playerControl in playerControls {
            playerControl.selectedSegmentIndex = Player.manual.rawValue
        }
        
        try? gameController.saveGame()
        gameController.newGame()
    }
    
    /// プレイヤーの行動を待ちます。
    func waitForPlayer() {
        guard let turn = gameController.turn else { return }
        switch Player(rawValue: playerControls[turn.index].selectedSegmentIndex)! {
        case .manual:
            break
        case .computer:
            gameController.playTurnOfComputer()
        }
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
    func updateCountLabels() {
        for side in Disk.sides {
            countLabels[side.index].text = "\(gameController.diskCount(of: side))"
        }
    }
    
    /// 現在の状況に応じてメッセージを表示します。
    func updateMessageViews() {
        switch gameController.turn {
        case .some(let side):
            messageDiskSizeConstraint.constant = messageDiskSize
            messageDiskView.disk = side
            messageLabel.text = "'s turn"
        case .none:
            if let winner = gameController.dominantSide() {
                messageDiskSizeConstraint.constant = messageDiskSize
                messageDiskView.disk = winner
                messageLabel.text = " won"
            } else {
                messageDiskSizeConstraint.constant = 0
                messageLabel.text = "Tied"
            }
        }
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
                        
            self.newGame()
            self.waitForPlayer()
            
            NotificationCenter.default.post(name: .ViewControllerReset, object: self)
        })
        present(alertController, animated: true)
    }
    
    /// プレイヤーのモードが変更された場合に呼ばれるハンドラーです。
    @IBAction func changePlayerControlSegment(_ sender: UISegmentedControl) {
        let side: Disk = Disk(index: playerControls.firstIndex(of: sender)!)
        
        try? gameController.saveGame()
        
        let player = Player(rawValue: sender.selectedSegmentIndex)!
        
        gameController.changePlayer(player, of: side)        
    }
}

extension ViewController: BoardViewDelegate {
    /// `boardView` の `location` で指定されるセルがタップされたときに呼ばれます。
    /// - Parameter boardView: セルをタップされた `BoardView` インスタンスです。
    /// - Parameter location: セルの位置です。
    func boardView(_ boardView: BoardView, didSelectCellAt location: Location) {
        guard let turn = gameController.turn else { return }
        guard case .manual = Player(rawValue: playerControls[turn.index].selectedSegmentIndex)! else { return }
        // try? because doing nothing when an error occurs
        do {
            
            try gameController.placeDisk(turn, at: location, animated: true)
            gameController.nextTurn()
        }
        catch _ {
            
        }
    }
}

// MARK: File-private extensions

extension Disk {
    init(index: Int) {
        for side in Disk.sides {
            if index == side.index {
                self = side
                return
            }
        }
        preconditionFailure("Illegal index: \(index)")
    }
    
    var index: Int {
        switch self {
        case .dark: return 0
        case .light: return 1
        }
    }
}

extension ViewController : GameControllerDelegate {
    
    func gameController(_ controller: GameController, gameWillStart _: Void) {
        
        preparingForNewGame = true
    }
    
    func gameController(_ controller: GameController, gameDidStartWithBoard board: Board) {

        preparingForNewGame = false
        
        clearViewUpdateRequests()
        updateBoard(board)
        updateMessageViews()
        updateCountLabels()
        
        for side in Disk.sides {

            let player = gameController.player(of: side)
            playerControls[side.index].selectedSegmentIndex = player.rawValue
        }
    }
    
    func gameController(_ controller: GameController, setDisk disk: Disk?, location: Location, animationDuration duration: Double) {

        viewUpdateProcessingQueue.async {
            
            self.viewUpdateRequestQueue.enqueue(.square(disk: disk, location: location))
            
            if duration != 0 {

                self.viewUpdateRequestQueue.enqueue(.sleep(interval: duration))
            }
        }
    }
    

    func gameController(_ controller: GameController, ponderingWillStartBySide side: Disk) {
        
        playerActivityIndicators[side.index].startAnimating()
    }
    
    func gameController(_ controller: GameController, ponderingDidEndBySide side: Disk) {
        
        playerActivityIndicators[side.index].stopAnimating()
    }
    
    func gameController(_ controller: GameController, turnChanged side: Disk) {
        
        updateCountLabels()
        updateMessageViews()
        waitForPlayer()
    }
    
    func gameController(_ controller: GameController, turnChangedButCannotMoveAnyware side: Disk) {
        
        updateMessageViews()
        
        let alertController = UIAlertController(
            title: "Pass",
            message: "Cannot place a disk.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { [unowned self] _ in
            self.gameController.nextTurn()
        })
        
        present(alertController, animated: true)
    }
    
    func gameController(_ controller: GameController, gameOverWithWinner side: Disk?) {
        
        updateMessageViews()
    }
}
