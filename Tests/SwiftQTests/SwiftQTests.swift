import XCTest
@testable import SwiftQ

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
        
        guard let json = try? example.fullJSON() else {
            XCTFail("JSON serialization failed")
            return
        }
        
        let jsonType = JSON(json)
        let string: String? = try? jsonType.get(key: "string")
        let int: Int? = try? jsonType.get(key: "int")
        let bool: Bool? = try? jsonType.get(key: "bool")
        
        XCTAssertEqual(string, String(describing: Example.self))
        XCTAssertEqual(int, 100)
        XCTAssertEqual(bool, true)
        
        let taskName: String? = try? jsonType.unsafeGet("taskName")
        let uuid: String? = try? jsonType.unsafeGet("uuid")
        let createdAt: Int? = try? jsonType.unsafeGet("createdAt")
        let taskType: String? = try? jsonType.unsafeGet("taskType")
        
        XCTAssertEqual(taskName, String(describing: Example.self))
        XCTAssertEqual(uuid, example.uuid)
        XCTAssertNotNil(createdAt)
        XCTAssertEqual(taskType, "task")
    }
    
    //MARK: - All Tests
    static var allTests = [
        ("testPeriodicTime", testPeriodicTime),
        ("testTask", testTask),
        ("testTime", testTime)
        ]
}

final class Example: Task {
    
    let id: Identification
    
    let string: String
    let int: Int
    let bool: Bool
    
    
    func execute() throws { }
    
    func json() throws -> JSON {
        return JSON([
            "string" : string,
            "int": int,
            "bool": bool
            ]
        )
    }
    
    init(string: String, int: Int, bool: Bool) {
        self.id = Identification()
        self.string = string
        self.int = int
        self.bool = bool
    }
    
    init(json: JSON) throws {
        self.id = try Identification(json)
        self.string = try json.get(key: "string")
        self.int = try json.get(key: "int")
        self.bool = try json.get(key: "bool")
    }
}
