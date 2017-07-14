![Merge](https://user-images.githubusercontent.com/8390081/28135754-b291cf38-671d-11e7-8a1e-669a36246057.png)

# SwiftQ

### What is it?
SwiftQ is a distributed task queue for server side swift applications.  Task queues are used as a mechanism to distribute work across machines.  SwiftQ uses messages to communicate between clients and workers.  In this case the message broker is Redis.  SwiftQ uses the [reliable queue pattern](https://redis.io/commands/rpoplpush).  This ensures that all tasks get processed even in the event of networking problems or consumer crashes.  SwiftQ can be used for real time operations as well as delayed execution of tasks.  SwiftQ can consist of multiple producers and consumers allowing for high availability and horizontal scaling.   

### Uses
SwiftQ is made to execute tasks outside of the usual HTTP request-response cycle.
Examples of this are
- Sending emails
- Recording metrics
- Deleting/deactivating data
- Talking with a third-party API
- Spreading out a large numbers of database inserts over time
- Processing images
- Creating thumbnails
- Anything that takes more than 200ms to accomplish

### Features

-  Scheduling tasks
-  Periodic tasks
-  Chaining tasks
-  Task dependency injection
-  Recovery strategies for task failure
-  At-least-once delivery

## Configuration
#### Redis Configuration

It is recommended that a separate Redis database is used to avoid conflicting name space.
```swift
let redisConfig = RedisConfig(redisDB: 0, hostname: "127.0.0.1", port: 6379, password: nil)

```

```swift
let configuration = Configuration(pollingInterval: 1000, 
                                  enableScheduling: true,
                                  concurrency: 4,
                                  redisConfig: .development,
                                  tasks: [Demo.self])
```
For convenience during development RedisConfig has a static variable `development` that returns a RedisConfig with the default hostname and port.  `pollingInterval` is the interval in milliseconds that SwiftQ will poll the scheduled queue.  `enableScheduling` can be set to false in order to disable a consumer from polling the scheduled queue.  Note polling is only used for monitoring the scheduled queue which uses Redis's Sorted set type.  For all other tasks Redis's BRPOPLPUSH command is used to determine when tasks are available to be executed.  All tasks must be registered in order for SwiftQ to process them.

## Usage

#### Producer

Defining a producer and pushing a task onto the task queue.
```swift
let producer = try SwiftQProducer(redisConfig: .development)
let demoTask = DemoTask()
try producer.enqueue(demoTask)
```
#### Consumer

Creating a consumer.  As soon as the consumer is started it will start processing tasks.  The consumer must be initialized with the types of tasks you want to consume.
```swift
let consumer = try SwiftQConsumer(configuration)
consumer.start()
```
Note a single app can be both a consumer and a producer, this may make deployment easier than having machines that are dedicated to being consumers. 

#### Creating tasks

Every task must conform to the Task protocol.  The Identification property is there to allow SwiftQ to store extra information on your model, things like id, number of execution attempts etc. 

```swift

final class DemoTask: Task {
    
    let id: Identification
    let url: String
    
    func execute() throws {
        // Make request
    }
    
    init(url: String) {
        self.url = url
        self.id = Identification()
    }
    
    func json() throws -> JSON {
        let json = ["url" : url]
        return JSON(json)
    }
    
    init(json: JSON) throws {
        self.url = try json.get("url")
        self.id = try Identification(json)
    }
}

```

####  Scheduling tasks
Scheduling is handy for things like sending follow up emails or sending reminders.  Any task is schedulable. 

```swift
try producer.enqueue(task: demo, time: .seconds(30))
```
This task will run in 30 seconds.

NOTE: The task does not fire exactly at the time supplied. Rather, once that time has past, the task moves from the scheduled queue to the work queue and will be completed as workers are free to process it.


####  Periodic tasks
Periodic tasks have many uses.  For example a web application could poll an API every 10 minutes to collect data. SwiftQ would handle invoking code to call the API, process the results and store them in a persistent database for later use by a client.

```swift
final class DemoTask: PeriodicTask {
    
    let id: Identification
    let url: String
    
    func execute() throws {
        // Make request
    }
    
    init(url: String) {
        self.url = url
        self.id = Identification()
    }
    
    func json() throws -> JSON {
        let json = ["url" : url]
        return JSON(json)
    }
    
    init(json: JSON) throws {
        self.url = try json.get("url")
        self.id = try Identification(json)
    }
    
    var frequency: PeriodicTime {
        return .daily(minute: 30, hour: 5)
    }
}

```
This task will run at 5:30 am every day. 
Periodic tasks must conform to the PeriodicTask protocol.

####  Chaining Tasks
Chaining encourages small single purpose tasks, allowing for easier testing.  It is supported via a set of protocols   Chainable, Linkable and Injectable.   

```swift
let addition = Add(5,5)
let multiplication = Multiply(by: 5)
let division = Divide(by: 5)
        
let chain = Chain(addition)
            .chain(task: multiplication)
            .chain(task: division)
        
try producer.enqueue(chain: chain)
```
This chain represents (5 + 5) x 5 / 5

Chains are run in a serial queue.  If one of the tasks in a chain throws an error, the remaining tasks are canceled.
Note: Chaining a task to the same task instance will result in undefined behavior.

####  Advanced Usage
By default all consumers consume tasks from the same queue.  You may want to specify a custom queue which only certain tasks are routed to.  To do this just add this to your task

```swift
var queue: String {
    return "custom"
}
```
You will also need to specify the custom queue in the consumer configuration.

Note: Consumers can only consume from one queue.

#### Supported Types
SwiftQ encodes tasks to JSON before sending them to the broker. Therefore only types with native JSON representation can be supported.  Supported types are:

- String
- Number
- array
- boolean

#### JSON Format
```JSON
{
  "taskName": "Demo",
  "args": {
    "email": "example@example.com"
  },
  "uuid": "40F2CD9F-5C00-470F-AC8C-F1B8EEDB5800",
  "timestamp": 1499820672090,
  "taskType": "task",
  "retryCount": 0
}
```
#### Installing
Update your Package.swift file with

```swift
.Package(url: "https://github.com/John-Connolly/SwiftQ.git", majorVersion: 0)
```
