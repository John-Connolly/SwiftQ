//
//  Preparations.swift
//  SwiftQ
//
//  Created by John Connolly on 2018-01-02.
//

import Foundation
import Async

public protocol Preparation {
    func prepare() -> Future<Void>
}

struct RestartPreparation: Preparation {
    
    func prepare() -> Future<Void> {
        
        return .done
    }
    
}


struct Preparations {
    
    let items: [Preparation]
    
    
    func run() -> Signal {
        
        var promises = [Promise<Void>]()
        
        for item in items {
            let promise = Promise<Void>()
            item.prepare().do {
                promise.complete()
                }.catch(promise.fail)
            promises.append(promise)
        }
        
        return promises
            .map { $0.future }
            .flatten()
    }
    
}
