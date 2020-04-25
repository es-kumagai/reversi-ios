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
    
    /// どちらの色のプレイヤーのターンかを表します。ゲーム終了時は `nil` です。
    private var turn: Disk? = .dark

    /// 新しいゲームを始める準備中に `true` になります。
    private var gameNumber: Int = 0
    private var preparingForNewGame: Bool = false

    private var viewUpdateProcessingQueue = DispatchQueue(label: "reversi.viewcontroller.animation")
    private var viewUpdateRequestQueue: Queue<ViewUpdateRequest> = []
    private var viewUpdateMessageLoopSource: DispatchSourceTimer!
    private var viewUpdateMessageLoopDuration = 0.3
    

    private var playerCancellers: [Disk: Canceller] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardView.delegate = self
        messageDiskSize = messageDiskSizeConstraint.constant
        
        let source = DispatchSource.makeTimerSource(flags: [], queue: viewUpdateProcessingQueue)
        
        source.schedule(deadline: .now(), repeating: viewUpdateMessageLoopDuration)
        source.setEventHandler(handler: diskChangeRequestMessageLoop)

        viewUpdateMessageLoopSource = source
        viewUpdateMessageLoopSource.resume()
        
        NotificationCenter.default.addObserver(forName: .GameControllerGameWillStart, object: nil, queue: nil) { [unowned self] notification in
            
            self.preparingForNewGame = true
        }

        NotificationCenter.default.addObserver(forName: .GameControllerGameDidStart, object: nil, queue: nil) { [unowned self] notification in
            
            self.preparingForNewGame = false
            self.gameNumber = notification.userInfo!["gameNumber"] as! Int
            
            let board = notification.userInfo!["board"] as! Board

            self.updateBoard(board)
            self.updateMessageViews()
            self.updateCountLabels()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(setDisk(_:)), name: .GameControllerDiskSet, object: nil)

        do {
            try loadGame()
        } catch _ {
            newGame()
        }
    }
    
    private var viewHasAppeared: Bool = false
    
    func diskChangeRequestMessageLoop() {
        
        guard let request = viewUpdateRequestQueue.dequeue(forGameNumber: gameNumber) else {
            
            return
        }
        
        // ゲーム開始の準備時はアニメーションを伴いません。
        let animated = !preparingForNewGame
        
        DispatchQueue.main.async {
            
            switch request {
                
            case .square(_, let disk, let location):
                self.boardView.set(disk: disk, location: location, animated: animated)
                
            case .board(gameNumber: _, board: let board):
                self.boardView.set(board: board, animated: animated)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewHasAppeared { return }
        viewHasAppeared = true
        waitForPlayer()
    }
}

// MARK: Reversi logics

extension ViewController {
    /// `side` で指定された色のディスクが盤上に置かれている枚数を返します。
    /// - Parameter side: 数えるディスクの色です。
    /// - Returns: `side` で指定された色のディスクの、盤上の枚数です。
    func countDisks(of side: Disk) -> Int {
        
        return gameController.board.squares
            .filter { $0.disk == side }
            .count
    }
    
    /// 盤上に置かれたディスクの枚数が多い方の色を返します。
    /// 引き分けの場合は `nil` が返されます。
    /// - Returns: 盤上に置かれたディスクの枚数が多い方の色です。引き分けの場合は `nil` を返します。
    func sideWithMoreDisks() -> Disk? {
        let darkCount = countDisks(of: .dark)
        let lightCount = countDisks(of: .light)
        if darkCount == lightCount {
            return nil
        } else {
            return darkCount > lightCount ? .dark : .light
        }
    }
    
    private func flippedDiskLocationsByPlacingDisk(_ disk: Disk, at location: Location) -> [Location] {
        
        guard gameController.disk(at: location) == nil else {
            return []
        }
        
        var diskLocations: [Location] = []
        
        for direction in Direction.allDirections {
            
            var location = location
            var diskLocationsInLine: [Location] = []
            
            flipping: while true {
                
                location = location.next(to: direction)
                
                guard gameController.board.contains(location) else {
                    
                    break flipping
                }
                
                switch (disk, gameController.disk(at: location)) { // Uses tuples to make patterns exhaustive
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
    
    /// `location` で指定されたセルに、 `disk` が置けるかを調べます。
    /// ディスクを置くためには、少なくとも 1 枚のディスクをひっくり返せる必要があります。
    /// - Parameter location: セルの位置です。
    /// - Parameter y: セルの行です。
    /// - Returns: 指定されたセルに `disk` を置ける場合は `true` を、置けない場合は `false` を返します。
    func canPlaceDisk(_ disk: Disk, at location: Location) -> Bool {
        !flippedDiskLocationsByPlacingDisk(disk, at: location).isEmpty
    }
    
    /// `side` で指定された色のディスクを置ける盤上のセルの座標をすべて返します。
    /// - Returns: `side` で指定された色のディスクを置ける盤上のすべてのセルの座標の配列です。
    func validMoves(for side: Disk) -> [Location] {
        var locations: [Location] = []
        
        for square in gameController.board.squares {
            if canPlaceDisk(side, at: square.location) {
                locations.append(square.location)
            }
        }
        
        return locations
    }
    
    /// `location` で指定されたセルに `disk` を置きます。
    /// - Parameter location: セルの位置です。
    /// - Parameter isAnimated: ディスクを置いたりひっくり返したりするアニメーションを表示するかどうかを指定します。
    /// - Parameter completion: アニメーション完了時に実行されるクロージャです。
    ///     このクロージャは値を返さず、アニメーションが完了したかを示す真偽値を受け取ります。
    ///     もし `animated` が `false` の場合、このクロージャは次の run loop サイクルの初めに実行されます。
    /// - Throws: もし `disk` を `location` で指定されるセルに置けない場合、 `DiskPlacementError` を `throw` します。
    func placeDisk(_ disk: Disk, at location: Location, animated isAnimated: Bool) throws {
        let diskLocations = flippedDiskLocationsByPlacingDisk(disk, at: location)
        if diskLocations.isEmpty {
            throw DiskPlacementError(disk: disk, location: location)
        }
        
        if isAnimated {
            animateSettingDisks(at: [location] + diskLocations, to: disk)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.gameController.set(disk, at: location)
                
                for location in diskLocations {
                    
                    self.gameController.set(disk, at: location)
                }
            }
        }
    }
    
    /// `locations` で指定されたセルに、アニメーションしながら順番に `disk` を置く。
    /// `locations` から先頭の座標を取得してそのセルに `disk` を置き、
    /// 残りの座標についてこのメソッドを再帰呼び出しすることで処理が行われる。
    /// すべてのセルに `disk` が置けたら `completion` ハンドラーが呼び出される。
    private func animateSettingDisks<C: Collection>(at locations: C, to disk: Disk)
        where C.Element == Location
    {
        
        for location in locations {
            
            gameController.set(disk, at: location)
        }

        try? saveGame()
        updateCountLabels()
    }
}

// MARK: Game management

extension ViewController {
    /// ゲームの状態を初期化し、新しいゲームを開始します。
    func newGame() {
        
        turn = .dark
        
        for playerControl in playerControls {
            playerControl.selectedSegmentIndex = Player.manual.rawValue
        }
        
        try? saveGame()
        gameController.newGame()
    }
    
    /// プレイヤーの行動を待ちます。
    func waitForPlayer() {
        guard let turn = self.turn else { return }
        switch Player(rawValue: playerControls[turn.index].selectedSegmentIndex)! {
        case .manual:
            break
        case .computer:
            playTurnOfComputer()
        }
    }
    
    /// プレイヤーの行動後、そのプレイヤーのターンを終了して次のターンを開始します。
    /// もし、次のプレイヤーに有効な手が存在しない場合、パスとなります。
    /// 両プレイヤーに有効な手がない場合、ゲームの勝敗を表示します。
    func nextTurn() {
        guard var turn = self.turn else { return }
        
        turn.flip()
        
        if validMoves(for: turn).isEmpty {
            if validMoves(for: turn.flipped).isEmpty {
                self.turn = nil
                updateMessageViews()
            } else {
                self.turn = turn
                updateMessageViews()
                
                let alertController = UIAlertController(
                    title: "Pass",
                    message: "Cannot place a disk.",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { [weak self] _ in
                    self?.nextTurn()
                })
                present(alertController, animated: true)
            }
        } else {
            self.turn = turn
            updateMessageViews()
            waitForPlayer()
        }
    }
    
    /// "Computer" が選択されている場合のプレイヤーの行動を決定します。
    func playTurnOfComputer() {
        guard let turn = self.turn else { preconditionFailure() }
        let location = validMoves(for: turn).randomElement()!
        
        playerActivityIndicators[turn.index].startAnimating()
        
        let cleanUp: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.playerActivityIndicators[turn.index].stopAnimating()
            self.playerCancellers[turn] = nil
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

// MARK: Views

extension ViewController {
    
    @objc func setDisk(_ notification: Notification) {

        let disk = notification.userInfo!["disk"] as! Disk?
        let location = notification.userInfo!["location"] as! Location
        let gameNumber = notification.userInfo!["gameNumber"] as! Int

        let request = ViewUpdateRequest.square(gameNumber: gameNumber, disk: disk, location: location)
        
        viewUpdateProcessingQueue.async {
            
            self.viewUpdateRequestQueue.enqueue(request)
        }
    }

    /// 盤面を一括で更新します。
    func updateBoard(_ board: Board) {
        
        let request = ViewUpdateRequest.board(gameNumber: gameNumber, board: board)
        
        viewUpdateProcessingQueue.async {
            
            self.viewUpdateRequestQueue.enqueue(request)
        }
    }

    /// 各プレイヤーの獲得したディスクの枚数を表示します。
    func updateCountLabels() {
        for side in Disk.sides {
            countLabels[side.index].text = "\(countDisks(of: side))"
        }
    }
    
    /// 現在の状況に応じてメッセージを表示します。
    func updateMessageViews() {
        switch turn {
        case .some(let side):
            messageDiskSizeConstraint.constant = messageDiskSize
            messageDiskView.disk = side
            messageLabel.text = "'s turn"
        case .none:
            if let winner = self.sideWithMoreDisks() {
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
            
            for side in Disk.sides {
                self.playerCancellers[side]?.cancel()
                self.playerCancellers.removeValue(forKey: side)
            }
            
            self.newGame()
            self.waitForPlayer()
            
            NotificationCenter.default.post(name: .ViewControllerReset, object: self)
        })
        present(alertController, animated: true)
    }
    
    /// プレイヤーのモードが変更された場合に呼ばれるハンドラーです。
    @IBAction func changePlayerControlSegment(_ sender: UISegmentedControl) {
        let side: Disk = Disk(index: playerControls.firstIndex(of: sender)!)
        
        try? saveGame()
        
        if let canceller = playerCancellers[side] {
            canceller.cancel()
        }
        
        if side == turn, case .computer = Player(rawValue: sender.selectedSegmentIndex)! {
            playTurnOfComputer()
        }
    }
}

extension ViewController: BoardViewDelegate {
    /// `boardView` の `location` で指定されるセルがタップされたときに呼ばれます。
    /// - Parameter boardView: セルをタップされた `BoardView` インスタンスです。
    /// - Parameter location: セルの位置です。
    func boardView(_ boardView: BoardView, didSelectCellAt location: Location) {
        guard let turn = turn else { return }
        guard case .manual = Player(rawValue: playerControls[turn.index].selectedSegmentIndex)! else { return }
        // try? because doing nothing when an error occurs
        do {
            
            try placeDisk(turn, at: location, animated: true)
            nextTurn()
        }
        catch _ {
            
        }
    }
}

// MARK: Save and Load

extension ViewController {
    private var path: String {
        (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("Game")
    }
    
    /// ゲームの状態をファイルに書き出し、保存します。
    func saveGame() throws {
        var output: String = ""
        output += turn.symbol
        for side in Disk.sides {
            output += playerControls[side.index].selectedSegmentIndex.description
        }
        output += "\n"
        
        for squaresPerRow in gameController.board.squaresPerRow {
            for square in squaresPerRow {
                output += square.disk.symbol
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
                let diskSymbol = line.popFirst(),
                let disk = Optional<Disk>(symbol: diskSymbol.description)
                else {
                    throw FileIOError.read(path: path, cause: nil)
            }
            turn = disk
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
            playerControls[side.index].selectedSegmentIndex = player.rawValue
        }
        
        do { // board
            guard lines.count == gameController.board.rows else {
                throw FileIOError.read(path: path, cause: nil)
            }
            
            NotificationCenter.default.post(name: .GameControllerGameWillStart, object: self, userInfo: ["gameNumber" : gameNumber])

            var row = 0
            while let line = lines.popFirst() {
                var col = 0
                for character in line {
                    let disk = Disk?(symbol: "\(character)").flatMap { $0 }
                    gameController.set(disk, at: Location(col: col, row: row))
                    col += 1
                }
                guard col == gameController.board.cols else {
                    throw FileIOError.read(path: path, cause: nil)
                }
                row += 1
            }
            guard row == gameController.board.rows else {
                throw FileIOError.read(path: path, cause: nil)
            }

            NotificationCenter.default.post(name: .GameControllerGameDidStart, object: self, userInfo: ["gameNumber" : gameNumber, "board" : gameController.board])
        }
        
        updateMessageViews()
        updateCountLabels()
    }
    
    enum FileIOError: Error {
        case write(path: String, cause: Error?)
        case read(path: String, cause: Error?)
    }
}

// MARK: Additional types

extension ViewController {
    enum Player: Int {
        case manual = 0
        case computer = 1
    }
}

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

extension Optional where Wrapped == Disk {
    fileprivate init?<S: StringProtocol>(symbol: S) {
        switch symbol {
        case "x":
            self = .some(.dark)
        case "o":
            self = .some(.light)
        case "-":
            self = .none
        default:
            return nil
        }
    }
    
    fileprivate var symbol: String {
        switch self {
        case .some(.dark):
            return "x"
        case .some(.light):
            return "o"
        case .none:
            return "-"
        }
    }
}
