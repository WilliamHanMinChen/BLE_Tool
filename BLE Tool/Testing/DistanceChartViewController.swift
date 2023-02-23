//
//  DistanceChartViewController.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/23.
//

import UIKit
import SwiftUI

class DistanceChartViewController: UIViewController {

    var contentView = UIHostingController(rootView: DistanceChart(capturedSignals: []))

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
    func refreshContent(capturedSignals: [DistanceReadings]){
        
        let minDistance = capturedSignals.min { $0.distance < $1.distance }
        let maxDistance = capturedSignals.max { $0.distance < $1.distance }
    
        
        let minDistanceVal = (minDistance?.distance ?? 0) * 0.8
        let maxDistanceVal = (maxDistance?.distance ?? 5) * 1.2
        
        let printstuff = print("Min Val: \(minDistanceVal), Max Val \(maxDistanceVal)")
        
        
        contentView.rootView.capturedSignals = capturedSignals
        
        contentView.rootView.minDistance = minDistanceVal
        
        contentView.rootView.maxDistance = maxDistanceVal
        
        contentView.rootView.minReading = minDistance
        
        contentView.rootView.maxReading = maxDistance
        
    }

}
