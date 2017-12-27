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
-  Non-blocking backpressure
-  Optimized for non-blocking operations.
-  Task dependency injection
-  Recovery strategies for task failure
-  At-least-once delivery

## Configuration
#### Redis Configuration

It is recommended that a separate Redis database is used to avoid conflicting name space.
```swift
let redisConfig = RedisConfiguration(redisDB: 0, hostname: "127.0.0.1", port: 6379, password: nil)

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
    
    func execute() -> Future<Void> {
        
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
    
    init(url: String) {
        self.storage = Storage(PollTask.self)
        self.url = url
    }
    
    func execute() -> Future<Void> {
        // Make request
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

##### Scheduler
The Scheduler represents an object that schedules units of work.  Theses units of work are called Processes.  You are able to create and register your own processes to perform work at certain intervals.  By default SwiftQ comes with 2 processes Heartbeat and Monitor.  This are uses to signal that the consumer is still alive and to monitor the processing queue for dead tasks.

##### At-least-once delivery
Often times distributed systems need to communicate asynchronously with one another.  In order to achieve this,  distributed systems use messages.  There are 3 types of types of delivery semantics for messages: at-most-once, at-least-once, and exactly-once.  The ideal solution solution is to have exactly-once delivery, this would prevent the possibility of tasks being ran more then once.  Although some message brokers such as Kafka claim to provide these semantics, it is often disputed that exactly-once delivery is not possible.  SwiftQ aims to provide at-least-once delivery.  In order to achieve this a couple things need to be in place. 

1. Multiple consumers have to be consuming from a queue.
2. The dead task monitor has to be actived. 
3. Redis needs to have persistence enabled.
4. (optional) Redis replication.

#### Idempotency
Because SwiftQ has at-least-once semantics it is possible for a task to be ran more than once.  Tasks should be idempotent, this means that if a task is ran more than once it should not change the result beyond the initial application.  This is particularly important for database writes.  All writes should be inside a transaction so they can be rolled back if an error occurs.


### Architecture
Under the hood SwiftQ is a classic producer-consumer problem whereby a Redis queue is effectively an unbounded producer.  In order to limit memory usage and increase performance almost everything is a reactive-stream.  Reactive streams provide non-blocking back pressure which is the key to SwiftQ’s low memory usage and high performance.

SwiftQ was designed in a way to effectively eliminate the need for locking resources.  It achieves this by having no shared state between threads.  Before version 1.0, SwiftQ had a thread safe connection pool.  This created a lot of contention when multiple threads were demanding a connection.

#### Eventloops
SwiftQ leverages Vapors Redis client.  The Redis Client uses asynchronous IO this helps SwiftQ utilize your CPU to its full capacity.  There are three main types of eventLoops Epoll, Kqueue and Dispatch.   A dispatch event loop is just a dispatch queue. The Epoll and Kqueue event loops are more optimized for asynchronous IO.

### The Big Picture



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
 .package(url: "https://github.com/John-Connolly/SwiftQ.git", .exact("1.0.0"))
```
