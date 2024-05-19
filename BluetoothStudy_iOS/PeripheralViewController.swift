//
//  PeripheralViewController.swift
//  BluetoothStudy_iOS
//
//  Created by 오킹 on 5/19/24.
//

import CoreBluetooth
import UIKit

class PeripheralViewController: UIViewController, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager?
    var transferCharacteristic: CBMutableCharacteristic?
    let transferServiceUUID = CBUUID(string: "1234")
    let transferCharacteristicUUID = CBUUID(string: "5678")
    let dataToSend = "Hello from Peripheral Device".data(using: .utf8)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startAdvertising()
        }
    }
    
    func startAdvertising() {
        transferCharacteristic = CBMutableCharacteristic(
            type: transferCharacteristicUUID,
            properties: [.notify, .write, .writeWithoutResponse],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        let transferService = CBMutableService(type: transferServiceUUID, primary: true)
        transferService.characteristics = [transferCharacteristic!]
        peripheralManager?.add(transferService)
        
        peripheralManager?.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [transferServiceUUID]
        ])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        peripheralManager?.updateValue(dataToSend, for: transferCharacteristic!, onSubscribedCentrals: nil)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid == transferCharacteristicUUID {
                if let value = request.value, let string = String(data: value, encoding: .utf8) {
                    print("Received data: \(string)")
                    peripheralManager?.respond(to: request, withResult: .success)
                }
            }
        }
    }
}
