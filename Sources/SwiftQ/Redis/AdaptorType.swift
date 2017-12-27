//
//  AdaptorType.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-26.
//

import Foundation
import Async

protocol AdaptorType: class {
    
    @discardableResult
    func execute(_ command: Command) throws -> Future<RedisResponseRepresentable>
    
    @discardableResult
    func pipeline(_ commands: () -> ([Command])) throws -> Future<[RedisResponseRepresentable]>
    
    init(config: RedisConfiguration, connections: Int, eventLoop: EventLoop) throws
    
}
