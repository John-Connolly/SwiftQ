//
//  ConsumerInfo.swift
//  SwiftQ
//
//  Created by John Connolly on 2019-01-02.
//

import Foundation

struct ConsumerInfo: Codable {
    var beat: Int
    let info: Info
    var busy: Int

    struct Info: Codable {
        let hostname: String
        let startedAt: Int
    }

    static var initial: ConsumerInfo {
        return .init(beat: Date().unixTime,
                     info: Info.init(hostname: Host().name,
                     startedAt:  Date().unixTime),
                     busy: 0)
    }

    mutating func incrHeartbeat() {
        beat = Date().unixTime
    }

    var allFields: [String: String] {
        return [
            ConsumerInfo.CodingKeys.beat.stringValue: beat.description,
            ConsumerInfo.CodingKeys.busy.stringValue: busy.description,
            ConsumerInfo.CodingKeys.info.stringValue: "",
        ]
    }

}
