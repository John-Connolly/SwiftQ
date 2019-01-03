//
//  SwiftQ + Dictionary.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-26.
//
//

import Foundation

extension Dictionary {
    
    func data() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self)
    }
}
