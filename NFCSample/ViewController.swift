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
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func didTapStart(_ sender: Any) {
        session = NFCNDEFReaderSession(delegate: self,
                                       queue: nil,
                                       invalidateAfterFirstRead: true)
        session.begin()
    }
    @IBAction func didTapStartScanning(_ sender: Any) {
        print("start scanning")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    @IBAction func didTapStopScanning(_ sender: Any) {
        print("stop scanning")
        centralManager.stopScan()
    }
    @IBAction func didTapConnectBLE(_ sender: Any) {
        connectTo(UUID: "14443C9D-F958-224A-1D22-40DAEC0902C5")
    }
    
    private func connectTo(UUID: String) {
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [NSUUID(uuidString: UUID)! as UUID])
        
        guard let peripheral = peripherals.first else {
            print("\(UUID)のperipheralが見つかりません。")
            return
        }
        
        self.peripheral = peripheral
        print("peripheral: \(peripheral)")
        print("BLE接続開始...")
        centralManager.connect(self.peripheral, options: nil)
    }
}


// MARK: NFCNDEFReaderSessionDelegate
extension ViewController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                print("typeNameFormat: \(record.typeNameFormat.rawValue)")
                if let type = String.init(data: record.type, encoding: .utf8) {
                    print("type: \(type)")
                }
                if let identifier = String.init(data: record.identifier, encoding: .utf8) {
                    print("identifier: \(identifier)")
                }
                print(NSData(data: record.payload))
                print(record.payload.map { String(format: "%.2hhx", $0) }.joined())
                if let payload = String.init(data: record.payload, encoding: .ascii) {
                    print("payload: \(payload)")
                }
            }
        }
        
        connectTo(UUID: "14443C9D-F958-224A-1D22-40DAEC0902C5")
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(#function, error)
    }
}


// MARK: CBCentralManagerDelegate
extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "Blank" {
            print("UUID: \(peripheral.identifier)")
        }
        print(peripheral)
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID : NSData] {
            print(serviceData)
        }
        print("-----------------------------------")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("BLE接続成功")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("BLE接続失敗")
    }
}
