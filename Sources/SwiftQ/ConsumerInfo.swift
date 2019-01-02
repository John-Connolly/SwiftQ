//
//  ConsumerInfo.swift
//  SwiftQ
//
//  Created by John Connolly on 2019-01-02.
//

import Foundation

struct ConsumerInfo: Codable {
    let beat: Int
    let info: Info
    let busy: Int

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

    var allFields: [String: String] {
        return [
            ConsumerInfo.CodingKeys.beat.stringValue: beat.description,
            ConsumerInfo.CodingKeys.busy.stringValue: busy.description,
            ConsumerInfo.CodingKeys.info.stringValue: "",
        ]
    }

}
