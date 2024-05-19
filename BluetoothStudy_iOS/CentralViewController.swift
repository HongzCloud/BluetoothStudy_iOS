//
//  CentralViewController.swift
//  BluetoothStudy_iOS
//
//  Created by 오킹 on 5/20/24.
//

import CoreBluetooth
import UIKit

class CentralViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var sendDataButton = UIButton(frame: .init(origin: .zero, size: .init(width: 400, height: 400)))
    
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    let transferServiceUUID = CBUUID(string: "1234")
    let transferCharacteristicUUID = CBUUID(string: "5678")
    let dataToSend = "Hello from Central Device".data(using: .utf8)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .brown
        sendDataButton.backgroundColor = .darkGray
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.view.addSubview(sendDataButton)
        self.sendDataButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [transferServiceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        centralManager.stopScan()
        discoveredPeripheral = peripheral
        discoveredPeripheral?.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([transferServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([transferCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == transferCharacteristicUUID {
                transferCharacteristic = characteristic
            }
        }
    }
    
    func sendData() {
        if let peripheral = discoveredPeripheral, let characteristic = transferCharacteristic {
            peripheral.writeValue(dataToSend, for: characteristic, type: .withResponse)
        }
    }
    
    @objc func sendButtonTapped(_ sender: UIButton) {
        if centralManager.state == .poweredOn {
            sendData()
        } else {
            print("Bluetooth is not powered on")
        }
    }
}
