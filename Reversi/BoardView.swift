import UIKit

private let lineWidth: CGFloat = 2

public class BoardView: UIView {
    private var cellViews: [CellView] = []
    private var actions: [CellSelectionAction] = []
    
    /// 盤の幅（ `8` ）を表します。
    public let width: Int = 8
    
    /// 盤の高さ（ `8` ）を返します。
    public let height: Int = 8
    
    /// 盤のセルの `x` の範囲（ `0 ..< 8` ）を返します。
    public let xRange: Range<Int>
    
    /// 盤のセルの `y` の範囲（ `0 ..< 8` ）を返します。
    public let yRange: Range<Int>
    
    /// セルがタップされたときの挙動を移譲するためのオブジェクトです。
    public weak var delegate: BoardViewDelegate?
    
    override public init(frame: CGRect) {
        xRange = 0 ..< width
        yRange = 0 ..< height
        super.init(frame: frame)
        setUp()
    }
    
    required public init?(coder: NSCoder) {
        xRange = 0 ..< width
        yRange = 0 ..< height
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        self.backgroundColor = UIColor(named: "DarkColor")!
        
        let cellViews: [CellView] = (0 ..< (width * height)).map { _ in
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
        
        for row in yRange {
            for col in xRange {
                let location = Location(col: col, row: row)
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
                
                if row == height - 1 {
                    NSLayoutConstraint.activate([
                        self.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: lineWidth),
                    ])
                }
                if col == width - 1 {
                    NSLayoutConstraint.activate([
                        self.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: lineWidth),
                    ])
                }
            }
        }
        
        reset()
        
        for row in yRange {
            for col in xRange {
                let location = Location(col: col, row: row)
                let cellView: CellView = self.cellView(at: location)!
                let action = CellSelectionAction(boardView: self, location: location)
                actions.append(action) // To retain the `action`
                cellView.addTarget(action, action: #selector(action.selectCell), for: .touchUpInside)
            }
        }
    }
    
    /// 盤をゲーム開始時に状態に戻します。このメソッドはアニメーションを伴いません。
    /// NOTE: アニメが伴っても良いのではないか？
    public func reset() {
        for row in  yRange {
            for col in xRange {
                setDisk(nil, at: Location(col: col, row: row), animated: false)
            }
        }
        
        setDisk(.light, at: Location(col: width / 2 - 1, row: height / 2 - 1), animated: false)
        setDisk(.dark, at: Location(col: width / 2, row: height / 2 - 1), animated: false)
        setDisk(.dark, at: Location(col: width / 2 - 1, row: height / 2), animated: false)
        setDisk(.light, at: Location(col: width / 2, row: height / 2), animated: false)
    }
    
    private func cellView(at location: Location) -> CellView? {
        guard xRange.contains(location.col) && yRange.contains(location.row) else { return nil }
        return cellViews[location.col * width + location.row]
    }
    
    /// `location` で指定されたセルの状態を返します。
    /// セルにディスクが置かれていない場合、 `nil` が返されます。
    /// - Parameter location: セルの位置です。
    /// - Returns: セルにディスクが置かれている場合はそのディスクの値を、置かれていない場合は `nil` を返します。
    public func disk(at location: Location) -> Disk? {
        cellView(at: location)?.disk
    }
    
    /// `location` で指定されたセルの状態を、与えられた `disk` に変更します。
    /// `animated` が `true` の場合、アニメーションが実行されます。
    /// アニメーションの完了通知は `completion` ハンドラーで受け取ることができます。
    /// - Parameter disk: セルに設定される新しい状態です。 `nil` はディスクが置かれていない状態を表します。
    /// - Parameter location: セルの位置です。
    /// - Parameter animated: セルの状態変更を表すアニメーションを表示するかどうかを指定します。
    /// - Parameter completion: アニメーションの完了通知を受け取るハンドラーです。
    ///     `animated` に `false` が指定された場合は状態が変更された後で即座に同期的に呼び出されます。
    ///     ハンドラーが受け取る `Bool` 値は、 `UIView.animate()`  等に準じます。
    public func setDisk(_ disk: Disk?, at location: Location, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let cellView = cellView(at: location) else {
            preconditionFailure() // FIXME: Add a message.
        }
        cellView.setDisk(disk, animated: animated, completion: completion)
    }
}

public protocol BoardViewDelegate: AnyObject {
    /// `boardView` の `location` で指定されるセルがタップされたときに呼ばれます。
    /// - Parameter boardView: セルをタップされた `BoardView` インスタンスです。
    /// - Parameter location: セルの位置です。
    func boardView(_ boardView: BoardView, didSelectCellAt location: Location)
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
