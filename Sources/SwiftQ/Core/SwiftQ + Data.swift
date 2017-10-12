//
//  SwiftQ + Data.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-26.
//
//

import Foundation

extension Data {
    
    func jsonDictionary<T: Hashable, U>(key: T.Type, value: U.Type) throws -> [T : U] {
        let object = try JSONSerialization.jsonObject(with: self, options: [.allowFragments]) as? [T : U]
        return object ?? [:]
    }
}
