//
//  Zeromq.swift
//  Zeromq
//
//  Created by Admin on 25.03.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

@objc(ReactNativeZeroMQiOS)
class Zeromq: NSObject, RCTBridgeModule {
    
    static func moduleName() -> String! {
        return "ReactNativeZeroMQiOS";
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc
    func printMessage(_ message: String) -> Void {
        print(message)
    }
}
