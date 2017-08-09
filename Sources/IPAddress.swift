//
//  IPAddress.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-08-08.
//
//

import Foundation

struct IPAddress {
    
    private let ips: [String]
    
    init() {
        self.ips = Host.current().addresses
    }
    
    var address: String {
        return ips
            .filter(isIpAddress)
            .filter(isBogon)
            .first ?? ""
    }
    
    /// IPV4 255.255.255.255
    /// Filters ipv6 addresses
    private func isIpAddress(_ ip: String) -> Bool {
        guard ip.characters.count <= 15 else {
            return false
        }
        
        guard ip.components(separatedBy: ".").count == 4 else {
            return false
        }
        
        return true
    }
    
    /// Filters bogon ip addresses
    private func isBogon(_ ip: String) -> Bool {
        let bogonSequence = ip.components(separatedBy: ".").prefix(2)
        
        guard bogonSequence.first != "10" else {
            return true
        }
        
        let bogon = bogonSequence.joined(separator: ".")
        let isBogon = ["127.0","169.254","192.168","172.16"].contains(bogon)
        
        return isBogon
    }
    
}
