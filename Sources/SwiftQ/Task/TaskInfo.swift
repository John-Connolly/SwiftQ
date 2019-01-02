//
//  TaskInfo.swift
//  SwiftQ
//
//  Created by John Connolly on 2018-12-29.
//

import Foundation

struct TaskInfo<T: Task>: Codable {
    let task: T
    let uuid: String
    let name: String
    var enqueuedAt: Int
    var retryCount = 0
    var taskType: TaskType

    init(_ task: T) {
        self.name = String(describing: T.self)
        self.task = task
        self.uuid = UUID().uuidString
        self.taskType = .task
        self.enqueuedAt = Date().unixTime
    }

}
