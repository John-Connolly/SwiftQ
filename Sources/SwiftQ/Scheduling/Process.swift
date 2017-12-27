//
//  Process.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation

protocol Process: EmptyInitializable {
    
    var repeating: DispatchTimeInterval { get }
    
    func event(container: Container) // Could call this handler?
    
}

protocol EmptyInitializable {
    init() throws
}
