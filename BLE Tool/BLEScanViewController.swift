//
//  BLEScanViewController.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/11.
//  This class was created to see whether we could use low level bluetooth mananger to capture the entire broadcasting packet,
//  Still in the process of tesintg...
//

import UIKit
import CoreBluetooth

class BLEScanViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    let RF = CBUUID.init(string: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
    let MokoSmart = CBUUID.init(string: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn {
            print("Started Scanning!")
            centralManager.scanForPeripherals(withServices: [])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral.name != nil {
            print("Discovered: \(peripheral.description)")
            print(advertisementData)
        }
        
    }
    

    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
