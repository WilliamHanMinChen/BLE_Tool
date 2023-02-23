//
//  TestInstructionsViewController.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/6.
//

import UIKit
import CoreLocation
import CoreBluetooth

class TestInstructionsViewController: UIViewController {
    
    
    

    @IBOutlet weak var setupLabel: UILabel!
    @IBOutlet weak var setUpInstructionsLabel: UILabel!
    @IBOutlet weak var moreDetailsLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var startTestButton: UIButton!
    
    //The beacon that the user is running the test on
    var beacon: CLBeacon?
    
    var beaconName: String?
    
    //The test type we are taking
    var testType: TestType?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        startTestButton.layer.cornerRadius = 10
        
        guard let testType = testType else {
            fatalError("Failed to get test type")
        }
        
        switch testType {
        case .SignalsCaptured:
            setUpInstructionsLabel.text =
            """
 1. Put the phone on the phone rack
 2. Put the beacon onto the beacon holder
 3. Put the rack 1 meter away from the Beacon holder
 """
            moreDetailsLabel.text = "Nothing much"
            linkLabel.text = "Nothing atm"
        case .DistanceVSRSSI:
            setUpInstructionsLabel.text =
            """
 1. Put the phone on the phone rack
 2. Put the beacon onto the beacon holder
 3. Put the rack 1 meter away from the Beacon holder
 """
            moreDetailsLabel.text = "Nothing much"
            linkLabel.text = "Nothing atm"
        case .Calibration:
            setUpInstructionsLabel.text =
            """
 1. Put the phone on the phone rack
 2. Put the beacon onto the beacon holder
 3. Put the rack 1 meter away from the Beacon holder
 """
            moreDetailsLabel.text = "Nothing much"
            linkLabel.text = "Nothing atm"
        }
        
        
        
    }
    

    @IBAction func startTestAction(_ sender: Any) {
        
        guard let testType = testType else {
            fatalError("No test type set")
        }
        
        switch testType{
        case .Calibration:
            performSegue(withIdentifier: "beforeToStartSegue", sender: nil)
        case .DistanceVSRSSI:
            performSegue(withIdentifier: "TestToDistanceTestSegue", sender: nil)
        case .SignalsCaptured:
            performSegue(withIdentifier: "TestToDistanceAccuracySegue", sender: nil)
        }
        
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "beforeToStartSegue" {
            let destination = segue.destination as! CalibrationTestViewController
            
            destination.beacon = self.beacon
            
            destination.beaconName = self.beaconName
        } else if segue.identifier == "TestToDistanceTestSegue" {
            let destination = segue.destination as! DistanceVSRSSITestViewController
            
            destination.beacon = self.beacon
            
            destination.beaconName = self.beaconName
            
        }else if segue.identifier == "TestToDistanceAccuracySegue" {
            let destination = segue.destination as! DistanceAccuracyTestViewController
            
            destination.beacon = self.beacon
            
            destination.beaconName = self.beaconName
            
        }
    }
    

}
