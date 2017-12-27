//
//  MonitorProcess.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation

struct MonitorProcess: Process {
    
    let repeating = DispatchTimeInterval.seconds(1)
    
    //TODO: Pass in name
    func event(container: Container) {
        guard let client = container.get(RedisContainer.self)?.client else {
            return
        }
        
        let command = Command.zrangebyscore(key: "name", min: "-inf", max: Date().unixTime.description)
        let data = client.execute(command: command).map(to: [Data].self) { resp in
            return try resp.array.or(throw: SwiftQError.noValue)
        }
        
        data.do { data in
            
            guard data.count > 0 else {
                return
            }
            
            // Transfer to work queue.
            
            
            }.catch { error in
                Logger.log(error, level: .warning)
        }
        
        print("working")
    }
    
    
}
