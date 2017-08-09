//
//  Chain.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-10.
//
//

import Foundation

public final class Chain {
    
    let head: Chainable
    
    let uuid: String
    
    var _tasks: [Linkable] = []
    
    var tail: Injectable?
    
    public init(_ head: Chainable) {
        self.uuid = UUID().uuidString
        self.head = head
    }
    
    init(_ tasks: [Task]) throws {
        guard let head = tasks.first as? Chainable, let tail = tasks.last as? Injectable else {
            throw SwiftQError.chainFailedToInitialize(tasks)
        }
        
        self.uuid = UUID().uuidString
        self.head = head
        self.tail = tail
        self._tasks = tasks.flatMap { $0 as? Linkable }
        
    }
    
    
    public func chain(task: Injectable) -> Chain {
        tail = task
        return self
    }
    
    
    public func chain(task: Linkable) -> Chain {
        _tasks.append(task)
        return self
    }
    
    
    private func set(injection: Type?, at index: Int) {
        if index == _tasks.count {
            tail?.injection = injection
        } else {
            _tasks[safe: index]?.injection = injection
        }
    }
    
    
    func execute(_ beforeHandler: (_ task: Task) -> (),
                 afterHandler: (_ task: Task) -> ()) throws {
        beforeHandler(head)
        try head.execute()
        afterHandler(head)
        set(injection: head.result, at: 0)
        
        try _tasks.enumerated().forEach { index, task in
            beforeHandler(task)
            try task.execute()
            afterHandler(task)
            set(injection: task.result, at: index + 1)
        }
        tail.map(beforeHandler)
        try tail?.execute()
        tail.map(afterHandler)
    }
    
    
    private var tasks: [Task] {
        var tasks = _tasks as [Task]
        tasks.insert(head, at: 0)
        if let tail = tail {
            tasks.append(tail)
        }
        return tasks
    }
    
    
    func serialized() throws -> Data {
        var json = [String : Any]()
        json["chain"] = try tasks.map { try $0.fullJSON() }
        json["taskType"] = TaskType.chain.rawValue
        return try json.data()
    }
    
}
