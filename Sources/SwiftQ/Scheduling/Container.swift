//
//  Container.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation

struct Container {
    
    let items: [String : ContainerItem]
    
    func get<T: ContainerItem>(_ item: T) -> T? {
        return items[item.name].flatMap { $0 as? T }
    }
}

protocol ContainerItem: EmptyInitializable {
    
    var name: String { get }
    
}
