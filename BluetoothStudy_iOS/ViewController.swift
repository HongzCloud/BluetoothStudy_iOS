//
//  ViewController.swift
//  BluetoothStudy_iOS
//
//  Created by 오킹 on 5/11/24.
//

import UIKit

import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager!
    var desiredPeripheralIdentifier: UUID!
    var connectedPeripheral: CBPeripheral?
    
    var blueToothDeviceList: [String] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var unlinkedDeviceLabel: UILabel!
    @IBOutlet weak var linkedDeviceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        self.tableView.dataSource = self
        
        unlinkedDeviceLabel.numberOfLines = 0
        linkedDeviceLabel.numberOfLines = 0
        
        // 원하는 주변 디바이스의 UUID 설정
        desiredPeripheralIdentifier = UUID(uuidString: "F9EE3ED6-05C6-C1FD-0D42-1D859FFDE562")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state, "central.state")
        if central.state == .poweredOn {
            // 스캔 시작
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print(peripheral.identifier, "연결할 수 있는 리스트")
        blueToothDeviceList.append(peripheral.identifier.uuidString + (peripheral.name ?? ""))
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }

        if peripheral.identifier == desiredPeripheralIdentifier {
            // 원하는 디바이스를 찾았으므로 연결 시도
            centralManager.connect(peripheral, options: nil)
            connectedPeripheral = peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 연결 성공
        linkedDeviceLabel.text = peripheral.identifier.uuidString
        print("Connected to peripheral")
        
        // 연결 완료 후 필요한 작업 수행
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // 연결 실패
        print("Failed to connect to peripheral")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // 연결 종료
        unlinkedDeviceLabel.text = peripheral.identifier.uuidString
        print("Disconnected from peripheral")
    }
    
    @IBAction func tappedBlueToothButton(_ sender: Any) {
        // Central Manager 초기화
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blueToothDeviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
        cell.label.text = blueToothDeviceList[indexPath.row]

        return cell
    }
}
