//
//  Queue.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

public struct Queue<Element> : ExpressibleByArrayLiteral {
    
    fileprivate var elements: Array<Element>

    public init() {

        elements = Array<Element>()
    }
    
    public init(arrayLiteral elements: Element...) {
        
        self.elements = elements
    }
    
    public mutating func enqueue(_ element: Element) {
        
        elements.insert(element, at: 0)
    }
    
    public mutating func dequeue() -> Element? {

        guard !isEmpty else {
            
            return nil
        }
        
        return elements.removeLast()
    }
    
    public var front: Element? {
        
        return elements.last
    }
    
    public var back: Element? {
        
        return elements.first
    }
    
    public var isEmpty: Bool {
        
        return elements.isEmpty
    }
    
    public var count: Int {
        
        return elements.count
    }
    
    public mutating func clear() {
        
        elements.removeAll()
    }
}

extension Queue : Sequence {
    
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
