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
        print(email)
        return loop.newSucceededFuture(result: ())
    }

}
