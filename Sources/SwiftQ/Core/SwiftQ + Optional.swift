//
//  SwiftQ + Optional.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-10-03.
//

import Foundation

extension Optional {
    
    func or(throw error: @autoclosure () -> Error) throws -> Wrapped {
        guard let value = self else { throw error() }
        return value
    }
    
}
