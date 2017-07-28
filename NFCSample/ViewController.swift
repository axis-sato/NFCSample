//
//  ViewController.swift
//  NFCSample
//
//  Created by Masahiko Sato on 2017/07/28.
//  Copyright © 2017年 Masahiko Sato. All rights reserved.
//

import UIKit
import CoreNFC

class ViewController: UIViewController {
    var session: NFCNDEFReaderSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        session = NFCNDEFReaderSession(delegate: self,
                                       queue: nil,
                                       invalidateAfterFirstRead: true)
        session.begin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let type = String.init(data: record.type, encoding: .utf8) {
                    print("type: \(type)")
                }
                if let identifier = String.init(data: record.identifier, encoding: .utf8) {
                    print("identifier: \(identifier)")
                }
                if let payload = String.init(data: record.payload, encoding: .utf8) {
                    print("payload: \(payload)")
                }
            }
        }
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(#function, error)
    }
}
