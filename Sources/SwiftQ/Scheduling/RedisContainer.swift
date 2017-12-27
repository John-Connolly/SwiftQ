//
//  RedisContainer.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation
import Async

final class RedisContainer: ContainerItem {
    
    let client: RedisAdaptor
    
    init() throws {
        let eventLoop = DispatchEventLoop(label: "swiftQ.eventloop.\(RedisContainer.name)")
        self.client = try RedisAdaptor(with: .development, connections: 1, on: eventLoop)
    }
    
}
