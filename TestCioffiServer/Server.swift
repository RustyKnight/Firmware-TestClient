//
//  Server.swift
//  TestCioffiServer
//
//  Created by Shane Whitehead on 22/07/2016.
//  Copyright © 2016 Beam Communications. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import SwiftyJSON
import CioffiAPI

class ServerService: NSObject {
    
    static let headerTag = 100
    static let bodyTag = 101
    
    static let ServerConnectedNotification: NSNotification.Name = NSNotification.Name("Server.connected")
    static let ServerDisconnectedNotification: NSNotification.Name = NSNotification.Name("Server.disconnected")
    
    static let ServerSentNotification: NSNotification.Name = NSNotification.Name("Server.sent")
    static let ServerRecivedNotification: NSNotification.Name = NSNotification.Name("Server.recived")
    
    static let urlKey = "Server.url"
    static let hostKey = "Server.host"
    static let errorKey = "Server.error"
    static let dataKey = "Server.data"

    static var readTimeout: TimeInterval = 30
    
    static let `default`: ServerService = ServerService()
    
    internal let socket: GCDAsyncSocket = GCDAsyncSocket()
    
    var header: Data?
    
    override init() {
    }
    
    var connected: Bool {
        return socket.isConnected
    }
    
    func connect(to host: String, port: UInt16) throws {
        if connected {
            disconnect()
        }
        socket.delegate = self
        socket.delegateQueue = DispatchQueue.global()
        try socket.connect(toHost: host, onPort: port)
    }
    
    func disconnect() {
        if connected {
            socket.disconnect()
            socket.delegate = nil
            socket.delegateQueue = nil
        }
    }
}

extension ServerService: GCDAsyncSocketDelegate {
    
    func send(request: RequestType) throws {
        let data = try ProtocolUtils.dataFor(request: request)
        log(info: "Writing \(String(data: data, encoding: String.Encoding.isoLatin1))")
        log(info: "Writing \(JSON(data: data))")
        socket.write(data, withTimeout: ServerService.readTimeout, tag: ServerService.headerTag)
    }
    
    func startReading() {
        readHeader(from: socket)
    }
    
    func readHeader(from sock : GCDAsyncSocket) {
        log(info: "Read header...")
        read(from: sock,
             toLength: ProtocolUtils.headerLength,
             tag: ServerService.headerTag)
    }
    
    func readBody(from sock : GCDAsyncSocket, toLength length: UInt) {
        log(info: "Body header...")
        read(from: sock,
             toLength: length,
             tag: ServerService.bodyTag)
    }
    
    func read(from sock : GCDAsyncSocket, toLength length: UInt, tag: Int) {
        log(info: "Read data toLength: \(length); tag: \(tag)")
        sock.readData(toLength: length,
                      withTimeout: ServerService.readTimeout,
                      tag: tag)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        log(info: "Did connect to \(url)")
        startReading()
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        log(info: "Did connect to \(host):\(port)")
        startReading()
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: NSError?) {
        log(info: "didDisconnect with \(err)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        log(info: "Wrote with tag \(tag)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        log(info: "dataRead withTag \(tag)")
        if tag == ServerService.headerTag {
            log(info: "Read header...")
            header = data
            let bodyLength = ProtocolUtils.getBodyLength(from: data)
            log(info: "Read body of \(bodyLength) bytes")
            readBody(from: sock, toLength: bodyLength)
        } else if tag == ServerService.bodyTag {
            log(info: "Read Body...")
            defer {
                header = nil
            }
            if let header = header {
                do {
                    try ProtocolUtils.processRequest(header: header,
                                                     body: data)
                } catch let error {
                    log(error: "\(error)")
                    // Send error response
                }
            }
            readHeader(from: sock)
        }
    }
    
}
