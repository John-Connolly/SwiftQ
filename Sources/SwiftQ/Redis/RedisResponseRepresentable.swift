//
//  RedisResponseRepresentable.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-26.
//

import Foundation

protocol RedisResponseRepresentable {
    
    var data: Foundation.Data? { get }
    
    var int: Int? { get }
    
    var string: String? { get }
    
    var array: [Foundation.Data]? { get }
    
}
