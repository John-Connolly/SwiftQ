import XCTest
import Dispatch
@testable import SwiftQ
@testable import Redis

class SwiftQTests: XCTestCase {
    
    
    // MARK: - Periodic Time
    func testPeriodicTime() {
        let time = Date().unixTime
        let periodicTime = PeriodicTime.secondly(time)
        let past = periodicTime.isPast(time: time)
        let nextTime = periodicTime.nextTime
        
        XCTAssertEqual(past, true)
        XCTAssertEqual(nextTime, (time * 2))
    }
    
    // MARK: - Time
    func testTime() {
        let seconds = Time.seconds(100).unixTime
        let minutes = Time.minutes(100).unixTime
        let days = Time.days(1).unixTime
        let weeks = Time.weeks(1).unixTime
        
        XCTAssertEqual(seconds, 100)
        XCTAssertEqual(minutes, 6000)
        XCTAssertEqual(days, 86_400)
        XCTAssertEqual(weeks, 604_800)
        
    }
    
    // MARK: - JSON serialization
    func testTask() {
        let example = Example(string: String(describing: Example.self), int: 100, bool: true)
        
        guard let data = try? example.data() else {
            XCTFail("JSON serialization failed")
            return
        }
     
        let task = try! Example(data: data)
        XCTAssertEqual(task.string, example.string)
        XCTAssertEqual(task.int, example.int)
        XCTAssertEqual(task.bool, example.bool)
        XCTAssertEqual(task.uuid, example.uuid)
        
        XCTAssertNotNil(task.storage.enqueuedAt)
        XCTAssertEqual(task.storage.name, String(describing: Example.self))
        XCTAssertEqual(task.storage.retryCount, example.storage.retryCount)
        
        let log = Log(message: "hello", consumer: "world", date: 200)
        task.storage.set(log: log)
        
        guard let taskData = try? task.data() else {
            XCTFail("JSON serialization failed")
            return
        }
        
        let taskWithLog = try! Example(data: taskData)
        XCTAssertEqual(taskWithLog.storage.log?.message, log.message)
        XCTAssertEqual(taskWithLog.storage.log?.consumer, log.consumer)
        XCTAssertEqual(taskWithLog.storage.log?.date, log.date)
    
    }
    
    func testDecoder() {
        let decoder = Decoder(types: [Example.self])
        let example = Example(string: "", int: 1, bool: true)
        let data = try! example.data()
        let task = try! decoder.decode(data: data)
        
        XCTAssertEqual(task.uuid, example.uuid)
        
    }
    
    
    func testCommand() {
        
        let multi = Command.multi
        let exec = Command.exec
        let select = Command.select(db: 0)
        let lrem = Command.lrem(key: "key", count: 0, value: "value")
        let lpush = Command.lpush(key: "key", values: ["value"])
        let lrange = Command.lrange(key: "key", start: 0, stop: 0)
        let brpoplpush = Command.brpoplpush(q1: "q1", q2: "q2", timeout: 0)
        let get = Command.get(key: "key")
        let set = Command.set(key: "key", value: "value")
        let incr = Command.incr(key: "key")
        let zadd = Command.zadd(queue: "key", score: "0", value: "value")
        let zrangebyscore = Command.zrangebyscore(key: "key", min: "min", max: "max")
        let zrem = Command.zrem(key: "key", values: ["value"])
        let sadd = Command.sadd(key: "key", value: "value")
        
        XCTAssertEqual(multi.data, [])
        XCTAssertEqual(exec.data, [])
        XCTAssertEqual(select.data, ["0".data])
        XCTAssertEqual(lrem.data, ["key".data, "0".data, "value".data])
        XCTAssertEqual(lpush.data, ["key".data, "value".data])
        XCTAssertEqual(lrange.data, ["key".data, "0".data, "0".data])
        XCTAssertEqual(brpoplpush.data, ["q1".data, "q2".data, "0".data])
        XCTAssertEqual(get.data, ["key".data])
        XCTAssertEqual(set.data, ["key".data, "value".data])
        XCTAssertEqual(incr.data, ["key".data])
        XCTAssertEqual(zadd.data, ["key".data, "0".data, "value".data])
        XCTAssertEqual(zrangebyscore.data, ["key".data, "min".data, "max".data])
        XCTAssertEqual(zrem.data, ["key".data, "value".data])
        XCTAssertEqual(sadd.data, ["key".data, "value".data])
    }
    
    let pool = try! ConnectionPool(max: 4) {
        return "Connection"
    }
    
    func testConnectionPool() {
        XCTAssertEqual(pool.connections.count, 4)
        let borrowed = pool.borrow()
        XCTAssertEqual(pool.connections.count, 3)
        XCTAssertEqual(borrowed, "Connection")
        
        
        
        DispatchQueue(label: "").asyncAfter(deadline: DispatchTime(secondsFromNow: 1)) {
            self.pool.takeBack(connection: "Connection")
            
        }
        
        _ = self.pool.borrow()
        _ = self.pool.borrow()
        _ = self.pool.borrow()
        _ = self.pool.borrow()
        XCTAssertEqual(pool.connections.count, 0)
    }
    
    
    
    //MARK: - All Tests
    static var allTests = [
        ("testPeriodicTime", testPeriodicTime),
        ("testTask", testTask),
        ("testTime", testTime),
        ("testDecoder", testDecoder),
        ("testCommand", testCommand),
        ("testConnectionPool",testConnectionPool)
    ]
}

extension SwiftQ.Command {
    
    var bytes: [[UInt8]] {
        return params.map { try! $0.makeBytes() }
    }
    
    var data: [Foundation.Data] {
        return bytes.map { Foundation.Data(bytes: $0) }
    }
    
}

extension String {
    
    var data: Foundation.Data {
        return self.data(using: .utf8)!
    }
    
}

// MARK: - Mocks
final class Example: Task {
    
    let storage: Storage
    
    let string: String
    let int: Int
    let bool: Bool
    
    func execute() throws { }
    
    init(string: String, int: Int, bool: Bool) {
        self.storage = Storage(Example.self)
        self.string = string
        self.int = int
        self.bool = bool
    }
    
}
