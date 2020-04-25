import UIKit

private let lineWidth: CGFloat = 2

public class BoardView: UIView {
    
    @IBOutlet private var gameController: GameController!
    
    /// 新しいゲームを始める準備中に `true` になります。
    private var preparingForNewGame: Bool = false
    
    private var cellViews: [CellView] = []
    private var actions: [CellSelectionAction] = []
    
    /// セルがタップされたときの挙動を移譲するためのオブジェクトです。
    weak var delegate: BoardViewDelegate?
    
    override public init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setUp()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDisk(_:)), name: .GameControllerDiskSet, object: nil)
        
        NotificationCenter.default.addObserver(forName: .GameControllerGameWillStart, object: nil, queue: nil) { notification in
            
            self.preparingForNewGame = true
        }

        NotificationCenter.default.addObserver(forName: .GameControllerGameDidStart, object: nil, queue: nil) { notification in
            
            self.preparingForNewGame = true
        }
    }

    private func setUp() {
        self.backgroundColor = UIColor(named: "DarkColor")!
        
        let cellViews: [CellView] = (0 ..< (gameController.board.squareCount)).map { _ in
            let cellView = CellView()
            cellView.translatesAutoresizingMaskIntoConstraints = false
            return cellView
        }
        self.cellViews = cellViews
        
        cellViews.forEach(self.addSubview(_:))
        for i in cellViews.indices.dropFirst() {
            NSLayoutConstraint.activate([
                cellViews[0].widthAnchor.constraint(equalTo: cellViews[i].widthAnchor),
                cellViews[0].heightAnchor.constraint(equalTo: cellViews[i].heightAnchor),
            ])
        }
        
        NSLayoutConstraint.activate([
            cellViews[0].widthAnchor.constraint(equalTo: cellViews[0].heightAnchor),
        ])
        
        for square in gameController.board.squares {
            
            let location = square.location
            let topNeighborAnchor: NSLayoutYAxisAnchor
            if let cellView = cellView(at: location.next(to: .top)) {
                topNeighborAnchor = cellView.bottomAnchor
            } else {
                topNeighborAnchor = self.topAnchor
            }
            
            let leftNeighborAnchor: NSLayoutXAxisAnchor
            if let cellView = cellView(at: location.next(to: .left)) {
                leftNeighborAnchor = cellView.rightAnchor
            } else {
                leftNeighborAnchor = self.leftAnchor
            }
            
            let cellView = self.cellView(at: location)!
            NSLayoutConstraint.activate([
                cellView.topAnchor.constraint(equalTo: topNeighborAnchor, constant: lineWidth),
                cellView.leftAnchor.constraint(equalTo: leftNeighborAnchor, constant: lineWidth),
            ])
            
            if location.row == gameController.board.rows - 1 {
                NSLayoutConstraint.activate([
                    self.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: lineWidth),
                ])
            }
            if location.col == gameController.board.cols - 1 {
                NSLayoutConstraint.activate([
                    self.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: lineWidth),
                ])
                
            }
        }
        
//        reset()
        
        for square in gameController.board.squares {
            let location = square.location
            let cellView: CellView = self.cellView(at: location)!
            let action = CellSelectionAction(boardView: self, location: location)
            actions.append(action) // To retain the `action`
            cellView.addTarget(action, action: #selector(action.selectCell), for: .touchUpInside)
        }
    }
        
    private func cellView(at location: Location) -> CellView? {
        
        guard gameController.board.contains(location) else { return nil }
        return cellViews[location.col * gameController.board.cols + location.row]
    }
}

private extension BoardView {
    
    @objc func setDisk(_ notification: Notification) {

        let disk = notification.userInfo!["disk"] as! Disk?
        let location = notification.userInfo!["location"] as! Location
        
        guard let cellView = cellView(at: location) else {
            preconditionFailure() // FIXME: Add a message.
        }
        
        // ゲーム開始の準備時はアニメーションを伴いません。
        let animated = !preparingForNewGame
        
        cellView.setDisk(disk, animated: animated)
    }
}

private class CellSelectionAction: NSObject {
    private weak var boardView: BoardView?
    let location: Location
    
    init(boardView: BoardView, location: Location) {
        self.boardView = boardView
        self.location = location
    }
    
    @objc func selectCell() {
        guard let boardView = boardView else { return }
        boardView.delegate?.boardView(boardView, didSelectCellAt: location)
    }
}
