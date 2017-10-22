//
//  PeriodicTask.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-17.
//
//

import Foundation


public protocol PeriodicTask: Task {
    
    var frequency: PeriodicTime { get }
}
