//
//  Container.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation

struct Container {
    
    let items: [String : ContainerItem]
    
    func get<T: ContainerItem>(_ item: T.Type) -> T? {
        return items[item.name].flatMap { $0 as? T }
    }
}

protocol ContainerItem: EmptyInitializable {
    
    static var name: String { get }
    
}

extension ContainerItem {
    
    static var name: String {
        return String(describing: self)
    }
    
}
