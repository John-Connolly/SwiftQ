//
//  AsyncRedis.swift
//  SwiftQ
//
//  Created by John Connolly on 2018-12-26.
//

import Foundation
import NIO

public final class AsyncRedis: ChannelDuplexHandler {

    public typealias InboundIn = RedisData
    public typealias OutboundIn = RedisData
    public typealias OutboundOut = [RedisData]

    let eventLoop: EventLoop
    let channel: Channel

    var awaiters: [([RedisData]) -> ()] = []

    init(_ eventLoop: EventLoop, channel: Channel) {
        self.channel = channel
        self.eventLoop = eventLoop
    }

    public static func connect(eventLoop: EventLoop) -> EventLoopFuture<AsyncRedis> {
        let bootstrap = ClientBootstrap(group: eventLoop)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                return channel.pipeline.add(handler: RedisEncoder()).then {
                    return channel.pipeline.add(handler: RedisDecoder())
                }
        }
        return bootstrap.connect(host: "127.0.0.1", port: 6379).then { channel in
            let redis = AsyncRedis(eventLoop, channel: channel)
            return channel.pipeline.add(handler: redis).map {
                return redis
            }
        }
    }

    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let input = unwrapInboundIn(data)
        let awaiter = awaiters.removeFirst()
        awaiter([input])
    }


    public func send(message: RedisData) -> EventLoopFuture<RedisData> {
        defer {
            channel.flush()
        }
        _ = channel.write(wrapOutboundOut([message]))

        let promise: EventLoopPromise<RedisData> = channel.eventLoop.newPromise()

        let awaiter = { (messages: [RedisData]) in
            promise.succeed(result: messages[0])
        }
        awaiters.append(awaiter)

        return promise.futureResult
    }

    public func pipeLineq(message: [RedisData]) -> EventLoopFuture<[RedisData]> {
        defer {
            channel.flush()
        }
        _ = channel.write(wrapOutboundOut(message))
        let promise: EventLoopPromise<[RedisData]> = channel.eventLoop.newPromise()
//        message.forEach
        let awaiter = { (messages: [RedisData]) in
            promise.succeed(result: messages)
        }
        awaiters.append(awaiter)
        return promise.futureResult
    }

    public func pipeLineStream(message: (StreamState) -> ()) {

    }

    func send(_ command: Command) -> EventLoopFuture<RedisData> {
        return send(message: .array(command.params2))
    }

//
//    func send(_ commands: [Command]) -> EventLoopFuture<RedisData> {
//        return send(message: .array(commands.flatMap { $0.params2 }))
//    }


}

public enum StreamState {
    case message(RedisData)
    case done
}

public indirect enum RedisData {
    case null
    case basicString(String)
    case bulkString(Data)
    case error(String)
    case integer(Int)
    case array([RedisData])

    var data: Data? {
        switch self {
        case .bulkString(let data):
            return data
        default: return nil
        }
    }

    var int: Int? {
        switch self {
        case .integer(let int):
            return int
        default: return nil
        }
    }
}

final class RedisEncoder: MessageToByteEncoder {

    typealias OutboundIn = [RedisData]

    func encode(ctx: ChannelHandlerContext, data: RedisEncoder.OutboundIn, out: inout ByteBuffer) throws {
        let encoded = data.map(encode).joined()
        out.write(bytes: encoded)
    }

    /// TODO: Switch to return data
    private func encode(data: RedisData) -> Data {
        switch data {
        case let .basicString(basicString):
            return Data("+\(basicString)\r\n".utf8)
        case let .error(err):
            return Data("-\(err)\r\n".utf8)
        case let .integer(integer):
            return Data(":\(integer)\r\n".utf8)
        case let .bulkString(bulkData):
//            let str = String(bytes: bulkData, encoding: .utf8)!
            return Data("$\(bulkData.count.description)\r\n".utf8) + bulkData + Data("\r\n".utf8)
        case .null:
            return Data("$-1\r\n".utf8)
        case let .array(array):
            let dataEncodedArray = array.map(encode(data:)).joined()
            return Data("*\(array.count)\r\n".utf8) + dataEncodedArray
        }
    }
    
}



let newline: UInt8 = 0xA
let carriageReturn: UInt8 = 0xD
let plus: UInt8 = 0x2B
let dollar: UInt8 = 0x24
let asterisk: UInt8 = 0x2A
let hyphen: UInt8 = 0x2d
let colon: UInt8 = 0x3a

extension String: Error { }

final class RedisDecoder: ByteToMessageDecoder {

    var cumulationBuffer: ByteBuffer?

    public typealias InboundOut = RedisData

    func decode(ctx: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        var position = 0
        switch try parse(at: &position, from: buffer) {
        case .notYetParsed:
            return .needMoreData
        case let .parsed(redisData):
            ctx.fireChannelRead(wrapInboundOut(redisData))
            buffer.moveReaderIndex(forwardBy: position)
            return .continue
        }
    }


    func parse(at position: inout Int, from buffer: ByteBuffer) throws -> PartialRedisData {
        guard let token = buffer.peekBytes(at: position, length: 1)?.first else {
            return .notYetParsed
        }
        position += 1
        switch token {
        case plus:
            guard let string = try parseSimpleString(at: &position, from: buffer) else { return .notYetParsed }
            return .parsed(.basicString(string))
        case hyphen:
            guard let string = try parseSimpleString(at: &position, from: buffer) else { return .notYetParsed }
            let error = "problem:" + string
            return .parsed(.error(error))
        case colon:
            guard let number = try integer(at: &position, from: buffer) else { return .notYetParsed }
            return .parsed(.integer(number))
        case dollar:
            return try parseBulkString(at: &position, from: buffer)
        case asterisk:
            return try parseArray(at: &position, from: buffer)
        default:
            throw "invalid token"
        }
    }

    private func parseArray(at position: inout Int, from buffer: ByteBuffer) throws -> PartialRedisData {
        guard let arraySize = try integer(at: &position, from: buffer) else { return .notYetParsed }
        guard arraySize > -1 else { return .parsed(.null) }

        var array = [PartialRedisData](repeating: .notYetParsed, count: arraySize)
        for index in 0..<arraySize {
            guard buffer.readableBytes - position > 0 else { return .notYetParsed }

            let parseResult = try parse(at: &position, from: buffer)
            switch parseResult {
            case .parsed:
                array[index] = parseResult
            default:
                return .notYetParsed
            }
        }

        let values = try array.map { partialRedisData -> RedisData in
            guard case .parsed(let value) = partialRedisData else {
                throw "Error!!!"
            }
            return value
        }

        return .parsed(.array(values))
    }

    private func parseSimpleString(at position: inout Int, from buffer: ByteBuffer) throws -> String? {
        //buffer.peekString
        let byteCount = buffer.readableBytes - position
        guard byteCount > 2 else { return nil } // terminatorToken guard to avoid bad access
        guard let bytes = buffer.peekBytes(at: position, length: byteCount) else { return nil }
        var offset = 0

        var carriageReturnFound = false

        // Loops until the carriagereturn
        detectionLoop: while offset < bytes.count {
            if bytes[offset] == carriageReturn {
                carriageReturnFound = true
                break detectionLoop
            }
            offset += 1
        }

        // Expects a carriage return
        guard carriageReturnFound else {
            return nil
        }

        // newline
        guard offset + 1 < bytes.count, bytes[offset + 1] == newline else {
            return nil
        }

        defer {
            // Move the pointer for recursive parsing...
            position += offset + 2
        }

        // Returns a String initialized with this data
        return String(bytes: bytes[..<offset], encoding: .utf8)
    }

    /// Parses an integer associated with the token at the provided position
    fileprivate func integer(at offset: inout Int, from input: ByteBuffer) throws -> Int? {
        // Parses a string
        guard let string = try parseSimpleString(at: &offset, from: input) else {
            return nil
        }

        guard let number = Int(string) else {
            throw "Unexpected"
        }
        return number
    }

    /// Parse a bulk string out
    fileprivate func parseBulkString(at position: inout Int, from buffer: ByteBuffer) throws -> PartialRedisData {
        guard let size = try integer(at: &position, from: buffer) else {
            return .notYetParsed
        }

        guard size > -1 else { return .parsed(.null) }
        guard buffer.readableBytes - position > (size + 1) else { return .notYetParsed }

        guard buffer.readableBytes > ("$\(size)\r\n".count + size + 2) else { return .notYetParsed }

        guard size > 0 else { // special case
            position += size + 2
            return .parsed(.bulkString(Data()))
        }

        let byteCount = buffer.readableBytes - position
        guard let bytes = buffer.peekBytes(at: position, length: byteCount) else { return .notYetParsed }

        defer { position += size + 2 }
        return .parsed(.bulkString(Data(bytes[..<size])))
    }
}

indirect enum PartialRedisData {
    case notYetParsed
    case parsed(RedisData)
}


extension ByteBuffer {
    internal func peekBytes(at skipping: Int = 0, length: Int) -> [UInt8]? {
        guard let bytes = getBytes(at: skipping + readerIndex, length: length) else { return nil }
        return bytes
    }
}

