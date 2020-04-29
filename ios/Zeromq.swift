import Foundation
import SwiftyZeroMQ5

extension String: Error {}

@objc(Zeromq)
class Zeromq: NSObject, RCTBridgeModule {
    
    var context: SwiftyZeroMQ.Context?
    var storage: [String: SwiftyZeroMQ.Socket] = [:]
    
    override init() {
        super.init()
        context = try? SwiftyZeroMQ.Context()
    }
    
    static func moduleName() -> String! {
        return "Zeromq"
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return false
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
            
            "ZMQ_DONTWAIT": SwiftyZeroMQ.SocketSendRecvOption.dontWait.rawValue,
            "ZMQ_NOBLOCK":  SwiftyZeroMQ.SocketSendRecvOption.dontWait.rawValue,
            "ZMQ_SNDMORE":  SwiftyZeroMQ.SocketSendRecvOption.sendMore.rawValue,
            
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
            if let zme = e as? SwiftyZeroMQ5.SwiftyZeroMQ.ZeroMQError {
                reject("ZMQERROR", zme.description, zme)
            } else {
                reject("ERROR", e.localizedDescription, e)
            }
        }
    }
    
    private func asyncTask(
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock,
        _ job: @escaping () throws -> Any?
    ) {
        DispatchQueue.global().async {
            self.task(resolve, reject, job)
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
            try context?.terminate()
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
            let socketType = try SwiftyZeroMQ.SocketType.init(sockType)
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
    func socketSend(_ uuid: String, body: [String], resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.asyncTask(resolve, reject) {
            let sock = try self.getObject(uuid)
            for data in body.dropLast() {
                try sock.send(string: data, options: .sendMore)
            }
            return try sock.send(string: body.last!, options: .none)
        }
    }
    
    @objc
    func socketSendBase64(_ uuid: String, body: [String], resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.asyncTask(resolve, reject) {
            let sock = try self.getObject(uuid)
            for data in body.dropLast() {
                try sock.send(data: Data(base64Encoded: data)!, options: .sendMore)
            }
            return try sock.send(data: Data(base64Encoded: body.last!)!, options: .none)
        }
    }
    
    @objc
    func socketRecv(_ uuid: String, flag: Int32, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.asyncTask(resolve, reject) {
            let sock = try self.getObject(uuid)
            let msg = try sock.recvMultipart()
            return msg.map { String(data: $0, encoding: String.Encoding.utf8) }
        }
    }
    
    @objc
    func socketRecvBase64(_ uuid: String, flag: Int32, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.asyncTask(resolve, reject) {
            let sock = try self.getObject(uuid)
            let msg = try sock.recvMultipart()
            return msg.map { $0.base64EncodedString() }
        }
    }
    
    @objc
    func socketRecvEvent(_ uuid: String, flags: Int32, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.asyncTask(resolve, reject) {
            let sock = try self.getObject(uuid)
            let msg = try sock.recvMultipart()
            if msg.count < 2 { return nil }
            
            let evt = msg[0]
            let eventStart = evt.startIndex
            let eventEnd = eventStart.advanced(by: MemoryLayout<Int16>.size)
            let valueStart = eventEnd
            let valueEnd = valueStart.advanced(by: MemoryLayout<Int32>.size)
            if evt.count != valueEnd { return nil }
            
            let event = evt[eventStart..<eventEnd].withUnsafeBytes { $0.load(as: Int16.self) }
            let value = evt[valueStart..<valueEnd].withUnsafeBytes { $0.bindMemory(to: Int32.self).baseAddress!.pointee }
            
            let address = String(data: msg[1], encoding: String.Encoding.utf8) ?? ""
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
    func setMaxReconnectInterval(_ uuid: String, value: Int32, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.setMaxReconnectInterval(value)
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
    
    @objc
    func setRouterHandover(_ uuid: String, value: Bool, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        self.task(resolve, reject) {
            let sock = try self.getObject(uuid)
            return try sock.setRouterHandover(value)
        }
    }
}
