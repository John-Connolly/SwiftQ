//
//  HeartBeatProcess.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation

struct HeartBeatProcess: Process {
    
    let repeating = DispatchTimeInterval.seconds(1)
    
    // TODO: Get consumer name.
    /// Sets a key in redis with the current time to indicate the consumer in alive.
    func event(container: Container) {
        let client = container.get(RedisContainer.self)?.client
        
        Date().unixTime.description.data(using: .utf8)
            .flatMap { time in
                client?.execute(command: .set(key: "consumerName", value: time))
            }?.catch { error in
                Logger.log(error)
        }
    
        print("heart beat")
    }
    
}
