<p align="center">
    <img src="https://user-images.githubusercontent.com/8390081/29257451-77c52e02-8088-11e7-80a8-385ef0dcce48.png"  alt="SwiftQ">
    <br>
    <br>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.0-brightgreen.svg" alt="Swift 4.0">
    </a>
</p>

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
                                  tasks: [EmailTask.self])
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

Every task must conform to the Task protocol.  The storage property is there to allow SwiftQ to store extra information on your model, things like id, number of execution attempts etc.  Tasks automatically conform to Codable.  If you need to provide custom encoding logic include `func encode(to encoder: Encoder) throws` in your task.

```swift

final class EmailTask: Task {
    
    let storage: Storage
    let email: String
    
    init(email: String) {
        self.storage = Storage(EmailTask.self)
        self.email = email
    }
    
    func execute() throws {
        
    }
}

```

####  Scheduling tasks
Scheduling is handy for things like sending follow up emails or sending reminders.  Any task is schedulable. 

```swift
try producer.enqueue(task: demo, time: .seconds(30))
```
This task will run in 30 seconds.

NOTE: The task does not fire exactly at the time supplied. Rather, once that time has passed, the task moves from the scheduled queue to the work queue and will be completed as workers are free to process it.


####  Periodic tasks
Periodic tasks have many uses.  For example a web application could poll an API every 10 minutes to collect data. SwiftQ would handle invoking code to call the API, process the results and store them in a persistent database for later use by a client.

```swift
final class PollTask: PeriodicTask {
    
    let storage: Storage
    let url: String
    
    func execute() throws {
        // Make request
    }
    
    init(url: String) {
        self.url = url
        self.storage = Storage(DemoTask.self)
    }
    
    var frequency: PeriodicTime {
        return .daily(minute: 30, hour: 5)
    }
}

```
This task will run at 5:30 am every day. 
Periodic tasks must conform to the PeriodicTask protocol.

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
- Array
- Boolean

#### JSON Format
```JSON
{
  "storage" : {
    "retryCount" : 0,
    "taskType" : "task",
    "name" : "EmailTask",
    "enqueuedAt" : 1507815271,
    "uuid" : "90872C7C-FCC8-4130-9872-87C619489664"
  },
  "email" : "example@example.com"
}

```
#### Installing
Update your Package.swift file with

```swift
.Package(url: "https://github.com/John-Connolly/SwiftQ.git", majorVersion: 0)
```
