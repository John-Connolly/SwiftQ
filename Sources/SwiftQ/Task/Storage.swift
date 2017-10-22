//
//  Storage.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-22.
//
//

import Foundation

public final class Storage: Codable {
    
    let uuid: String
    
    let name: String
    
    var enqueuedAt: Int?
    
    var retryCount = 0
    
    var taskType: TaskType
    
    var log: Log?
    
    public init<T: Task>(_ type: T.Type) {
        self.name = String(describing: type)
        self.uuid = UUID().uuidString
        self.taskType = .task
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Storage.CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(enqueuedAt ?? Date().unixTime, forKey: .enqueuedAt)
        try container.encode(retryCount, forKey: .retryCount)
        try container.encode(taskType, forKey: .taskType)
        try container.encodeIfPresent(log, forKey: .log)
    }
    
    func set(log: Log) {
        self.log = log
    }
    
    func set(type: TaskType) {
        self.taskType = type
    }
    
    func incRetry() {
        retryCount += 1
    }
    
}

struct Log: Codable {
    
    let message: String
    let consumer: String
    let date: Int
    
}

public enum TaskType: String, Codable {
    
    case task
    case scheduled
    case periodic
    
}
