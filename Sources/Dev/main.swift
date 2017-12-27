
import Foundation
import SwiftQ
import Redis
import Async


let config = Configuration(pollingInterval: 100,
                           enableScheduling: true,
                           concurrency: 2,
                           redisConfig: .development,
                           tasks: [EmailTask.self])

let app = try App(with: config)
try app.run()


//let queue = DispatchEventLoop(label: "eventloop.14.consumer")


//queue.async {
//      (1...200).forEach { _ in
//       let emailTask = EmailTask(email: "johndoe@example.com")
//       let producer = try! Producer(with: .development, on: queue)
//       try! producer.enqueue(emailTask)
//    }
//}
//RunLoop.main.run()


///
//let tasks = (1...5000).map { _ in
//    return EmailTask(email: "johndoe@example.com")
//}
//
//try (1...200).forEach { _ in
//    let resp = try producer.enqueue(tasks: tasks).blockingAwait()
//    print(resp)
//}

//let eventLoop = DispatchEventLoop(label: "eventloop.1.consumer")
////
//let UUIDs = (1...1000).map { num -> RedisData in
//    if num == 1 {
//        return RedisData(bulk:"myList")
//    } else {
//        return RedisData(bulk: UUID().uuidString)
//    }
//}
//
//eventLoop.async {
//    (1...100).forEach { _ in
//        let client = try! RedisClient.connect(on: eventLoop)
//        client.run(command: "LPUSH", arguments: UUIDs)
//    }
//
//}



//let eventLoop = DispatchEventLoop(label: "eventloop.1.consumer")
//let dataStream = DataStream(on: eventLoop)
//
//
//dataStream.drain { upStream in
//    upStream.request()
//    }.output { data in
////        print(data)
//        dataStream.request()
//    }.catch { error in
//        print(error)
//    }.finally {
//        print("finally")
//}
//
//
//let eventLoop2 = DispatchEventLoop(label: "eventloop.2.consumer")
//let dataStream2 = DataStream(on: eventLoop2)
//
//
//dataStream2.drain { upStream in
//    upStream.request()
//    }.output { data in
//        //        print(data)
//        dataStream2.request()
//    }.catch { error in
//        print(error)
//    }.finally {
//        print("finally")
//}
//
//
//
//let eventLoop3 = DispatchEventLoop(label: "eventloop.3.consumer")
//let dataStream3 = DataStream(on: eventLoop3)
//
//
//dataStream3.drain { upStream in
//    upStream.request()
//    }.output { data in
//        //        print(data)
//        dataStream3.request()
//    }.catch { error in
//        print(error)
//    }.finally {
//        print("finally")
//}
//
//let eventLoop4 = DispatchEventLoop(label: "eventloop.4.consumer")
//let dataStream4 = DataStream(on: eventLoop4)
//
//
//dataStream4.drain { upStream in
//    upStream.request()
//    }.output { data in
//        //        print(data)
//        dataStream4.request()
//    }.catch { error in
//        print(error)
//    }.finally {
//        print("finally")
//}
//
//
//let eventLoop5 = DispatchEventLoop(label: "eventloop.5.consumer")
//let dataStream5 = DataStream(on: eventLoop5)
//
//
//dataStream5.drain { upStream in
//    upStream.request()
//    }.output { data in
//        //        print(data)
//        dataStream5.request()
//    }.catch { error in
//        print(error)
//    }.finally {
//        print("finally")
//}
//
//let eventLoop6 = DispatchEventLoop(label: "eventloop.6.consumer")
//let dataStream6 = DataStream(on: eventLoop6)
//
//
//dataStream6.drain { upStream in
//    upStream.request()
//    }.output { data in
//        //        print(data)
//        dataStream6.request()
//    }.catch { error in
//        print(error)
//    }.finally {
//        print("finally")
//}
//
//let eventLoop7 = DispatchEventLoop(label: "eventloop.7.consumer")
//let dataStream7 = DataStream(on: eventLoop7)
//
//
//dataStream7.drain { upStream in
//    upStream.request()
//    }.output { data in
//        //        print(data)
//        dataStream7.request()
//    }.catch { error in
//        print(error)
//    }.finally {
//        print("finally")
//}


//RunLoop.main.run()



