
import Foundation
import SwiftQ
import Redis
import Async


////let emailTask = EmailTask(email: "johndoe@example.com")
let consumer = Consumer(types: [EmailTask.self])

consumer.run()
//

let queue = DispatchQueue(label: "main.euwhf.e324",qos: .background)//, qos: .background
////
let producer = try Producer(on: queue)
//
let tasks = (1...5000).map { _ in
    return EmailTask(email: "johndoe@example.com")
}

try (1...200).forEach { _ in
    let resp = try producer.enqueue(tasks: tasks).blockingAwait()
    print(resp)
}





//queue.async {
//    try! RedisClient.connect(on: queue).do { client in
//        return client.run(command: "BRPOPLPUSH", arguments: ["myList","newList","0"])
//    }
//    
//}

//var client: Any! = nil
//
//queue.async {
//    client = try! RedisClient.connect(on: queue).map { client -> RedisClient in
//        client.run(command: "BRPOPLPUSH", arguments: ["myList","newList","0"])
//        //        client.getData(forKey: "foo").do(future.complete).catch(future.fail)
//        return client
//    }
//}
//
//RunLoop.main.run()

