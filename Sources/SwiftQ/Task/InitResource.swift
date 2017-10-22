//
//  InitResource.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-10-06.
//

import Foundation

struct InitResource {
    
    let name: String
    let type: Task.Type
    
    init(_ type: Task.Type) {
        self.name = String(describing: type)
        self.type = type
    }
    
}
