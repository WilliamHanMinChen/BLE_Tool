//
//  ChartsViewController.swift
//  BLE Tool
//
//  This ViewController Hosts a swiftUI view controller
//  Created by William Chen on 2023/2/23.
//


import UIKit
import SwiftUI

class ChartsViewController: UIViewController {
    
    var contentView = UIHostingController(rootView: RSSIChart(capturedSignals: []))

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addChild(contentView)
        view.addSubview(contentView.view)
        
        //Set the constraints
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    
    //Refresh our
    func refreshContent(capturedSignals: [Readings]){
        
        let minRSSI = capturedSignals.min { $0.RSSI < $1.RSSI }
        let maxRSSI = capturedSignals.max { $0.RSSI < $1.RSSI }
    
        
        let minRSSIVal = (minRSSI?.RSSI ?? -60) - 10
        let maxRSSIVal = (maxRSSI?.RSSI ?? -20) + 10
        
        let printstuff = print("Min Val: \(minRSSIVal), Max Val \(maxRSSIVal)")
        
        
        contentView.rootView.capturedSignals = capturedSignals
        
        contentView.rootView.minRSSIVal = minRSSIVal
        
        contentView.rootView.maxRSSIVal = maxRSSIVal
        
        contentView.rootView.minReading = minRSSI
        
        contentView.rootView.maxReading = maxRSSI
        
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


