//
//  ViewController.swift
//  NFCSample
//
//  Created by Masahiko Sato on 2017/07/28.
//  Copyright © 2017年 Masahiko Sato. All rights reserved.
//

import UIKit
import CoreNFC
import CoreBluetooth

class ViewController: UIViewController {
    var session: NFCNDEFReaderSession!
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCentralManager()
    }
}

// MARK: Event
extension ViewController {
    @IBAction func didTapStartNFCSession(_ sender: Any) {
        log?.debug("start NFC Session")
        startNFCSession()
    }
    
    @IBAction func didTapStartBLEScan(_ sender: Any) {
        log?.debug("start BLE scan")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    @IBAction func didTapStopBLEScan(_ sender: Any) {
        log?.debug("stop BLE scan")
        centralManager.stopScan()
    }
    @IBAction func didTapConnectBLE(_ sender: Any) {
        connectTo(id: "14443C9D-F958-224A-1D22-40DAEC0902C5")
    }
}


// MARK: NFCNDEFReaderSessionDelegate
extension ViewController: NFCNDEFReaderSessionDelegate {
    private func setupCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func startNFCSession() {
        session = NFCNDEFReaderSession(delegate: self,
                                       queue: nil,
                                       invalidateAfterFirstRead: true)
        session.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                log?.debug("typeNameFormat: \(record.typeNameFormat.rawValue)")
                if let type = String.init(data: record.type, encoding: .utf8) {
                    log?.debug("type: \(type)")
                }
                if let identifier = String.init(data: record.identifier, encoding: .utf8) {
                    log?.debug("identifier: \(identifier)")
                }
                log?.debug(NSData(data: record.payload))
                log?.debug(record.payload.map { String(format: "%.2hhx", $0) }.joined())
                if let payload = String.init(data: record.payload, encoding: .ascii) {
                    log?.debug("payload: \(payload)")
                }
            }
        }
        
        connectTo(id: "14443C9D-F958-224A-1D22-40DAEC0902C5")
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        log?.error(error)
    }
}


// MARK: CBCentralManagerDelegate
extension ViewController: CBCentralManagerDelegate {
    private func connectTo(id: String) {
        guard let id = UUID(uuidString: id) else {
        log?.error("UUID生成に失敗")
            return
        }
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [id])
        
        guard let peripheral = peripherals.first else {
            log?.error("\(id)のperipheralが見つかりません。")
            return
        }
        
        self.peripheral = peripheral
        log?.debug("peripheral: \(peripheral)")
        log?.debug("BLE接続開始...")
        centralManager.connect(self.peripheral, options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log?.debug(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "Blank" {
            log?.debug("UUID: \(peripheral.identifier)")
        }
        log?.debug(peripheral)
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID : NSData] {
            log?.debug(serviceData)
        }
        log?.debug("-----------------------------------")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log?.debug("BLE接続成功")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log?.debug("BLE接続失敗")
    }
}
