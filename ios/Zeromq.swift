import Foundation
import SwiftyZeroMQ5

extension String: Error {}

@objc(Zeromq)
class Zeromq: NSObject, RCTBridgeModule {
    
    var context: SwiftyZeroMQ.Context?
    var storage: [String: SwiftyZeroMQ.Socket] = [:]
    
    static func moduleName() -> String! {
        return "Zeromq"
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    override init() {
        super.init()
        context = try? SwiftyZeroMQ.Context()
    }
    
    @objc
    func constantsToExport() -> [AnyHashable: Any]! {
        return [
            "ZMQ_REP":    SwiftyZeroMQ.SocketType.reply.rawValue,
            "ZMQ_REQ":    SwiftyZeroMQ.SocketType.request.rawValue,
            "ZMQ_XREP":   SwiftyZeroMQ.SocketType.xreply.rawValue,
            "ZMQ_XREQ":   SwiftyZeroMQ.SocketType.xrequest.rawValue,
            
            "ZMQ_PUB":    SwiftyZeroMQ.SocketType.publish.rawValue,
            "ZMQ_SUB":    SwiftyZeroMQ.SocketType.subscribe.rawValue,
            "ZMQ_XPUB":   SwiftyZeroMQ.SocketType.xpublish.rawValue,
            "ZMQ_XSUB":   SwiftyZeroMQ.SocketType.xsubscribe.rawValue,
            
            "ZMQ_DEALER": SwiftyZeroMQ.SocketType.dealer.rawValue,
            "ZMQ_ROUTER": SwiftyZeroMQ.SocketType.router.rawValue,
            "ZMQ_PAIR":   SwiftyZeroMQ.SocketType.pair.rawValue,

            "ZMQ_EVENT_CONNECTED":       SwiftyZeroMQ.SocketEvents.connected.rawValue,
            "ZMQ_EVENT_CONNECT_DELAYED": SwiftyZeroMQ.SocketEvents.connectDelayed.rawValue,
            "ZMQ_EVENT_CONNECT_RETRIED": SwiftyZeroMQ.SocketEvents.connectRetried.rawValue,
            "ZMQ_EVENT_LISTENING":       SwiftyZeroMQ.SocketEvents.listening.rawValue,
            "ZMQ_EVENT_BIND_FAILED":     SwiftyZeroMQ.SocketEvents.bindFailed.rawValue,
            "ZMQ_EVENT_ACCEPTED":        SwiftyZeroMQ.SocketEvents.accepted.rawValue,
            "ZMQ_EVENT_ACCEPT_FAILED":   SwiftyZeroMQ.SocketEvents.acceptFailed.rawValue,
            "ZMQ_EVENT_CLOSED":          SwiftyZeroMQ.SocketEvents.closed.rawValue,
            "ZMQ_EVENT_CLOSE_FAILED":    SwiftyZeroMQ.SocketEvents.closeFailed.rawValue,
            "ZMQ_EVENT_DISCONNECTED":    SwiftyZeroMQ.SocketEvents.disconnected.rawValue,
            "ZMQ_EVENT_MONITOR_STOPPED": SwiftyZeroMQ.SocketEvents.monitorStopped.rawValue,
            "ZMQ_EVENT_ALL":             SwiftyZeroMQ.SocketEvents.all.rawValue,
        ]
    }
    
    private func task(_ resolve: RCTPromiseResolveBlock, _ reject: RCTPromiseRejectBlock, _ job: () throws -> Any?) {
        do {
            let result = try job()
            resolve(result)
        } catch (let e) {
            reject("ZMQERROR", e.localizedDescription, e)
        }
    }
    
    private func newObject(_ obj: SwiftyZeroMQ.Socket) -> String {
        let uuid = UUID()
        storage[uuid.uuidString] = obj
        return uuid.uuidString
    }
    
    private func getObject(_ uuid: String) throws -> SwiftyZeroMQ.Socket {
        guard let obj = storage[uuid] else {
            throw "No such object with key \(uuid)"
        }
        return obj
    }
    
    private func delObject(_ uuid: String!) -> Bool {
        return storage.removeValue(forKey: uuid) != nil
    }
    
    private func closeContext(_ forced: Bool) throws -> Bool {
        if (storage.count == 0 || forced) {
            if (context != nil) {
                try context?.terminate()
                context = nil
            }
            return true
        }
        return false
    }
    
    private func socket(_ sockType: SwiftyZeroMQ.SocketType) throws -> SwiftyZeroMQ.Socket {
        if (context == nil) {
            context = try SwiftyZeroMQ.Context()
        }
        return try context!.socket(sockType)
    }
    
    @objc
    func socketCreate(_ sockType: Int32, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            guard let socketType = SwiftyZeroMQ.SocketType.init(rawValue: sockType) else {
                throw "Unknown sockType \(sockType)"
            }
            let sock = try self.socket(socketType)
            return self.newObject(sock)
        }
    }
    
    @objc
    func socketBind(_ uuid: String, endpoint: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.bind(endpoint)
        }
    }
    
    @objc
    func socketConnect(_ uuid: String, endpoint: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.connect(endpoint)
        }
    }
    
    @objc
    func socketDisconnect(_ uuid: String, endpoint: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.disconnect(endpoint)
        }
    }
    
    @objc
    func socketClose(_ uuid: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            try sock.close()
            return self.delObject(uuid)
        }
    }
    
    @objc
    func destory(_ forced: Bool, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            return try self.closeContext(forced)
        }
    }
    
    @objc
    func setSocketIdentity(_ uuid: String, value: String?, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.setIdentity(value)
        }
    }
    
    @objc
    func socketSend(_ uuid: String, body: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            for data in body.dropLast() {
                try sock.send(string: data, options: .sendMore)
            }
            return try sock.send(string: body.last!, options: .none)
        }
    }
    
    @objc
    func socketRecv(_ uuid: String, flag: Int32, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            let msg = try sock.recvMultipart()
            return msg.map { String(data: $0, encoding: String.Encoding.utf8) }
        }
    }
    
    @objc
    func socketRecvEvent(_ uuid: String, flags: Int32, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            let msg = try sock.recvMultipart()
            let event = msg[0].withUnsafeBytes { $0.load(as: Int16.self) }
            let value = msg[0].withUnsafeBytes { $0.load(fromByteOffset: 2, as: Int32.self) }
            let address = String(data: msg[0], encoding: String.Encoding.utf8) ?? ""
            return [ "event": event, "address": address, "value": value ] as [String : Any]
        }
    }
    
    @objc
    func socketSubscribe(_ uuid: String, topic: String?, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.setSubscribe(topic)
        }
    }
    
    @objc
    func socketUnsubscribe(_ uuid: String, topic: String?, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.setUnsubscribe(topic)
        }
    }
    
    @objc
    func socketMonitor(_ uuid: String, endpoint: String, events: Int32, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.monitor(endpoint, events: SwiftyZeroMQ.SocketEvents.init(rawValue: events))
        }
    }
    
    @objc
    func setSendTimeOut(_ uuid: String, value: Int32, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.setSendTimeout(value)
        }
    }
    
    @objc
    func setReceiveTimeOut(_ uuid: String, value: Int32, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.setRecvTimeout(value)
        }
    }
    
    @objc
    func setImmediate(_ uuid: String, value: Bool, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.setImmediate(value)
        }
    }
    
    @objc
    func setLinger(_ uuid: String, value: Int32, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.setLinger(value)
        }
    }
}
