//
//  FeildDecoder.swift
//  SwiftQ
//
//  Created by John Connolly on 2019-01-14.
//

import Foundation

final class TaskLayoutDecoder: Swift.Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    var info: [FieldInfo] = []
    
    struct FieldInfo {
        let name: String
        let type: String
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(KDC(self))
    }
    
    struct KDC<Key: CodingKey>: KeyedDecodingContainerProtocol {
        func superDecoder() throws -> Swift.Decoder {
            fatalError()
        }
        
        func superDecoder(forKey key: Key) throws -> Swift.Decoder {
            fatalError()
        }
        
        var codingPath: [CodingKey] = []
        var allKeys: [Key] = []
        let decoder: TaskLayoutDecoder
        
        init(_ decoder: TaskLayoutDecoder) {
            self.decoder = decoder
        }
        
        func contains(_ key: Key) -> Bool {
            return true
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            
            return true
        }
        
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return false
        }
        
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return ""
        }
        
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return 0
        }
        
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            decoder.info.append(.init(name: key.stringValue, type: String(describing: type)))
            return try T(from: decoder)
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            fatalError()
        }
        
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SVDC(self)
    }
    
    struct SVDC: SingleValueDecodingContainer {
        var codingPath: [CodingKey] = []
        
        func decodeNil() -> Bool {
            return true
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            return false
        }
        
        func decode(_ type: String.Type) throws -> String {
            return ""
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            return 0
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            return 0
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            return 0
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            return 0
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            return 0
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            return 0
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            return 0
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            return 0
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            return 0
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            return 0
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            return 0
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            return 0
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try T(from: decoder)
        }
        
        let decoder: TaskLayoutDecoder
        init(_ decoder: TaskLayoutDecoder) {
            self.decoder = decoder
        }
    }
    
}
