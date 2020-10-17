//
//  SocketIOManager.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import SocketIO

final class SocketIOManager: NSObject {
    
    static let shared = SocketIOManager()
    
    let manager:SocketManager!
    let socket:SocketIOClient!
    
    weak var msgVC:MessagesVC?
    weak var chatVC:ChatViewController?
    
    var isConnected:Bool = false
    override init() {
        self.manager = SocketManager(socketURL: URL.init(string: CHAT_URL)!, config: [.log(false), .compress])
        self.socket = self.manager.defaultSocket
        
        super.init()
    }
    
    func establishConnection() {
        if self.socket.status == .disconnected || self.socket.status == .notConnected {
            self.socket.connect()
        }
        self.addListners()
        self.msgVC?.viewModel.refresh()
    }
    
    func disconnect() {
        self.isConnected = false
        self.socket.disconnect()
    }
    private func addListners() {
        self.didConnect()        
    }
    private func didConnect() {
        SocketIOManager.shared.socket.on("connect") { (data, ack) in
            print("### connected")            
            self.isConnected = true
        }
    }
}
