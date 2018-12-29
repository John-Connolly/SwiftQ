//
//  AsyncWorker.swift
//  SwiftQ
//
//  Created by John Connolly on 2018-12-28.
//

import Foundation


final class AsyncWorker {

    let queue: AsyncReliableQueue
    let decoder: Decoder

    init(queue: AsyncReliableQueue, decoder: Decoder) {
        self.queue = queue
        self.decoder = decoder
    }


    func run() {
        queue.blockingDequeue { data in
            switch data {
            case .bulkString(let data):
                let task = try! self.decoder.decode(data: data) // FIXME!!
//                task.execute(loop: self.redis.eventLoop).whenComplete {
//                    self.complete(task: data).whenComplete {
//
//                    }
//                }
            default: ()
            }
        }
    }
}
