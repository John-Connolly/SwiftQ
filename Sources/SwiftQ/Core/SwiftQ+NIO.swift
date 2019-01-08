//
//  SwiftQ+NIO.swift
//  SwiftQ
//
//  Created by John Connolly on 2019-01-08.
//

import Foundation
import NIO


extension EventLoop {

    func newFuture<T>(from f: () throws -> T) -> EventLoopFuture<T> {
        do {
            return newSucceededFuture(result: try f())
        } catch {
            return newFailedFuture(error: error)
        }
    }

}

func flatten<T>(array: [EventLoopFuture<T>], on eventLoop: EventLoop) -> EventLoopFuture<[T]> {
    var expectations: [T] = []
    let promise: EventLoopPromise<[T]> = eventLoop.newPromise()
    array.forEach { future in
        future.whenSuccess { item in
            expectations.append(item)
            if expectations.count == array.count {
                promise.succeed(result: expectations)
            }
        }
        future.whenFailure { error in
            promise.fail(error: error)
        }

    }
    return promise.futureResult
}
