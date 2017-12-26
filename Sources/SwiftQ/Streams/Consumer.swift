////
////  Consumer.swift
////  SwiftQ
////
////  Created by John Connolly on 2017-12-02.
////
//
import Foundation
import Async

final class Consumer {
    
    
    let eventLoops = (1...4).map { num -> DispatchEventLoop in
        let eventLoop =  DispatchEventLoop(label: "swiftQ.eventloop.\(num)")
        return eventLoop
    }
    
    
    private let decoder: DecoderStream
    
    init() {
        self.decoder = DecoderStream([]) // GET Types From config
        //   let _ = self.stream(to: decoder)
    }
    
}
