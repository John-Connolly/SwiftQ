//
//  Email.swift
//  Dev
//
//  Created by John Connolly on 2018-12-28.
//

import Foundation
import NIO
import SwiftQ

struct Email: Task {

    let email: String

    func execute(loop: EventLoop) -> EventLoopFuture<()> {

//        let promise: EventLoopPromise<()> = loop.newPromise()
//        _ = loop.scheduleTask(in: TimeAmount.seconds(1)) {
//            promise.succeed(result: ())
//        }
//        print(email)
        return loop.newSucceededFuture(result: ())
    }

}
