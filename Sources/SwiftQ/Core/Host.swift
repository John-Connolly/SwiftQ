//
//  Host.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-08-11.
//
//

import Foundation
#if os(Linux)
    import Glibc
#endif

struct Host {
    
    let name: String

    init() {
        self.name = Host.currentHostName()
    }
    
    /// https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/Host.swift
    private static func currentHostName() -> String {
        let hname = UnsafeMutablePointer<Int8>.allocate(capacity: Int(NI_MAXHOST))
        defer {
            hname.deallocate()
        }
        let r = gethostname(hname, Int(NI_MAXHOST))
        if r < 0 || hname[0] == 0 {
            return "localhost"
        }
        return String(cString: hname)
    }
    
}
