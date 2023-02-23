//
//  BeaconDetailsViewController.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/6.
//

import UIKit
import CoreLocation
import CoreBluetooth

enum TestType{
    case Calibration
    case DistanceVSRSSI
    case SignalsCaptured
}

class BeaconDetailsViewController: UIViewController, CLLocationManagerDelegate {
    
    //The beacon that the user tapped
    var beacon: CLBeacon?
    
    var beaconName: String?
    
    //Location manager
    var locationManager: CLLocationManager = CLLocationManager()
    
    var selectedTest: TestType = .Calibration
    
    
    @IBOutlet weak var majorLabel: UILabel!
    
    @IBOutlet weak var minorLabel: UILabel!
    
    @IBOutlet weak var rssiLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var calibrationButton: UIButton!
    
    @IBOutlet weak var distanceButton: UIButton!
    
    @IBOutlet weak var signalsCapturedButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let beacon = beacon else {
            fatalError("No beacon set!")
        }
        
        locationManager.delegate = self
        
        majorLabel.text = "Major: \(beacon.major.stringValue)"
        minorLabel.text = "Minor: \(beacon.minor.stringValue)"
        
        self.title = beaconName!
        
        calibrationButton.layer.cornerRadius = 10
        
        distanceButton.layer.cornerRadius = 10
        
        signalsCapturedButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let beacon = beacon else {
            fatalError("No beacon set!")
        }
        
        //Start polling this beacon
        let constraint = CLBeaconIdentityConstraint(uuid: beacon.uuid, major: CLBeaconMajorValue(beacon.major.intValue), minor: CLBeaconMinorValue(beacon.minor.intValue))
        
        locationManager.startRangingBeacons(satisfying: constraint)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let beacon = beacon else {
            fatalError("No beacon set!")
        }
        
        //Stop polling this beacon
        let constraint = CLBeaconIdentityConstraint(uuid: beacon.uuid, major: CLBeaconMajorValue(beacon.major.intValue), minor: CLBeaconMinorValue(beacon.minor.intValue))
        
        locationManager.stopRangingBeacons(satisfying: constraint)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        //Update our labels
        rssiLabel.text = "RSSI: \(beacons.first!.rssi.description)"
        
        let distance = String(format: "%.2f", beacons.first!.accuracy)
        
        distanceLabel.text = "Distance: \(distance)m "
        
    }
    
    
    @IBAction func calibrationAction(_ sender: Any) {
        selectedTest = .Calibration
        performSegue(withIdentifier: "BeaconToTestOnboardingSegue", sender: nil)
    }
    
    @IBAction func distanceAction(_ sender: Any) {
        selectedTest = .DistanceVSRSSI
        performSegue(withIdentifier: "BeaconToTestOnboardingSegue", sender: nil)
    }
    
    @IBAction func signalsCapturedAction(_ sender: Any) {
        selectedTest = .SignalsCaptured
        performSegue(withIdentifier: "BeaconToTestOnboardingSegue", sender: nil)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Give the next VC the selected beacon's details
        if segue.identifier == "BeaconToTestOnboardingSegue" {
            let destination = segue.destination as! TestInstructionsViewController
            
            destination.beacon = self.beacon
            
            destination.beaconName = self.beaconName
            
            destination.testType = self.selectedTest
        }
    }
    

}
