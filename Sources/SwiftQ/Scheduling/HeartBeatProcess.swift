//
//  HeartBeatProcess.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation

struct HeartBeatProcess: Process {
    
    let repeating = DispatchTimeInterval.seconds(1)
    
    func event(container: Container) {
        print("heart beat")
    }
    
}
