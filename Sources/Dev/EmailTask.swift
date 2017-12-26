//
//  EmailTask.swift
//  Development
//
//  Created by John Connolly on 2017-10-11.
//

import Foundation
import SwiftQ
import Async

final class EmailTask: Task {

    let storage: Storage
    let email: String
    
    init(email: String) {
        self.storage = Storage(EmailTask.self)
        self.email = email
    }
    
    func execute() -> Future<()> {
        return Future(())
    }
    
}


