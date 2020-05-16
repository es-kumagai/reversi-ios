//
//  Queue.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

/// FIFO を表現するデータ型です。
public struct Queue<Element> : ExpressibleByArrayLiteral {
    
    /// 内部に持つデータです。
    fileprivate var elements: Array<Element>
    
    /// 空のキューを生成します。
    public init() {

        elements = Array<Element>()
    }
    
    /// 配列リテラルからキューを生成します。
    /// - Parameter elements: <#elements description#>
    public init(arrayLiteral elements: Element...) {
        
        self.elements = elements
    }
    
    /// キューに値を挿入します。
    /// - Parameter element: 挿入する値です。
    public mutating func enqueue(_ element: Element) {
        
        elements.insert(element, at: 0)
    }
    
    /// キューから値を取得します。
    /// - Returns: 取得した値です。値がない場合は `nil` を返します。
    public mutating func dequeue() -> Element? {

        guard !isEmpty else {
            
            return nil
        }
        
        return elements.removeLast()
    }
    
    /// キューが空であるかを判定します。
    public var isEmpty: Bool {
        
        return elements.isEmpty
    }
    
    /// キューに保持されている要素の数を取得します。
    public var count: Int {
        
        return elements.count
    }
    
    /// キュー内の要素を削除します。
    public mutating func clear() {
        
        elements.removeAll()
    }
}

extension Queue : Sequence {
    
    /// 要素を取得するイテレーターを生成します。
    /// - Returns: イテレーターを生成して返します。
    public func makeIterator() -> QueueGenerator<Element> {
        
        return QueueGenerator(self)
    }
}

public struct QueueGenerator<T> : IteratorProtocol {
    
    fileprivate var generator: IndexingIterator<Array<T>>
    
    fileprivate init(_ queue: Queue<T>) {
        
        generator = queue.elements.makeIterator()
    }
    
    public mutating func next() -> T? {
        
        return generator.next()
    }
}
