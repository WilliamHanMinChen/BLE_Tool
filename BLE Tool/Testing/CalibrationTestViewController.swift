//
//  CalibrationTestViewController.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/6.
//

import UIKit
import CoreLocation
import CoreBluetooth
import SwiftCSVExport
import SwiftUI

class Readings: NSObject {
    var time: Date
    var RSSI: Int
    
    init(time: Date, RSSI: Int) {
        self.time = time
        self.RSSI = RSSI
    }
}

class DistanceReadings: NSObject {
    var time: Date
    var distance: Float
    
    init(time: Date, distance: Float) {
        self.time = time
        self.distance = distance
    }
}

class CalibrationTestViewController: UIViewController, CLLocationManagerDelegate {
    
    
    //References
    @IBOutlet weak var testTypeLabel: UILabel!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var dataPointsLabel: UILabel!
    
    @IBOutlet weak var rssiLabel: UILabel!
    
    @IBOutlet weak var restartButton: UIButton!
    
    @IBOutlet weak var resultsButton: UIButton!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    //The beacon that the user is running the test on
    var beacon: CLBeacon?
    
    var beaconName: String?
    
    //Location manager
    var locationManager: CLLocationManager = CLLocationManager()
    
    var running : Bool = false
    //Counter to display the number of data points we have
    var counter = 0
    //Holds our array of readings to be outputted
    var dataPoints : [Readings] = []

    
    //The time that is needed for the test to finish
    var testTime: Double = 30
    
    //Keeps track of the start time
    var startTime: Date?
    
    //FileName
    var savedFileName: String?
    
    //SwiftUI View Controller (For charts)
    @IBOutlet weak var chartsHostingVC: UIView!
    
    //The Charts VC that we need to refresh
    var chartsVC : ChartsViewController?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        
        
        restartButton.layer.cornerRadius = 10
        resultsButton.layer.cornerRadius = 10
        
        //Start the test
        runTest()
    }
    
    func runTest(){
        
        guard let beacon = beacon else {
            fatalError("No beacon set!")
        }
        
        //Stop polling this beacon
        let constraint = CLBeaconIdentityConstraint(uuid: beacon.uuid, major: CLBeaconMajorValue(beacon.major.intValue), minor: CLBeaconMinorValue(beacon.minor.intValue))
        locationManager.stopRangingBeacons(satisfying: constraint)
        
        locationManager.startRangingBeacons(satisfying: constraint)
        
        startTime = Date()
        
        var timer = Timer()
        
        running = true
        
        dataPoints = []
        
        //Hide buttons
        doneButton.isHidden = true
        
        resultsButton.isHidden = true
        
        progressLabel.text = "Capturing..."
        
        rssiLabel.text = "RSSI: NA Average: NA"
        
        dataPointsLabel.text = "Datapoints: 0"
        
        chartsVC?.refreshContent(capturedSignals: [])
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: running, block: { Timer in
            
            
            self.progressBar.progress = Float(Date().timeIntervalSince(self.startTime!) / self.testTime)
            
            if Date().timeIntervalSince(self.startTime!) > self.testTime + 1 {
                //Do UI Updates when we have finished the test
                self.running = false
                self.doneButton.isHidden = false
                self.resultsButton.isHidden = false
                self.progressLabel.text = "Test finished"
                self.locationManager.stopRangingBeacons(satisfying: constraint)
                
                self.testFinished()
                timer.invalidate()
            }
            
        })
        
    }
    
    func testFinished(){
        
        //Getting the time completed
        let date = Date()
        let timeFormatted = date.getFormattedDate(format: "yyyy-MM-dd-HH-mm-ss")
        
        //Get the beacon name and major
        guard let beacon = beacon else{
            fatalError("Failed to set beacon")
        }
        
        guard let beaconName = beaconName else {
            fatalError("Failed to get beacon name")
        }
        
        var fileName = timeFormatted + "-" + "Calibration" + "-" + beaconName
        fileName += "-" + beacon.major.intValue.description + "-" + beacon.minor.intValue.description
        
        
        // Add dictionary into rows of CSV Array
        let data:NSMutableArray  = NSMutableArray()
        //Output to CSV
        for dataPoint in dataPoints {
            
            let dataPointData: NSMutableDictionary = NSMutableDictionary()
            dataPointData.setObject(dataPoint.RSSI, forKey: "RSSI Readings" as NSCopying);
            data.add(dataPointData);
            
        }
        
        // Add fields into columns of CSV headers
        let header = ["RSSI Readings"]
        
        // Create a object for write CSV
        let writeCSVObj = CSV()
        writeCSVObj.rows = data
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        writeCSVObj.name = fileName
        
        
        // Write File using CSV class object
        let result = CSVExport.export(writeCSVObj)
        
        
        savedFileName = fileName
        
        print("Exported")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        rssiLabel.text = "RSSI: \(beacons.first!.rssi.description)"
        
        //Create the reading and add it
        let reading = Readings(time: Date(), RSSI: beacons.first!.rssi)
        //Add it to our list
        dataPoints.append(reading)
        
        dataPointsLabel.text = "Datapoints: \(dataPoints.count.description)"
        
        //Refresh our SwiftUI Charts
        chartsVC?.refreshContent(capturedSignals: dataPoints)
        
        //Calculate our average RSSI:
        var totalRSSI = 0
        for dataPoint in self.dataPoints {
            totalRSSI += dataPoint.RSSI
        }
        
        var averageRSSI = 0
        if totalRSSI != 0 {
            averageRSSI = totalRSSI/self.dataPoints.count
        }
        
        self.rssiLabel.text = self.rssiLabel.text! + " Average: \(averageRSSI)"
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    //Button Actions
    @IBAction func restartAction(_ sender: Any) {
        runTest()
    }
    
    
    @IBAction func sendResultsAction(_ sender: Any) {
        
        //Get the file URL
        //Get the paths
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //Gets the documents directory
        let fileDirectory = URL(string: paths[0].description + "Exports/" + savedFileName! + ".csv")!

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(fileDirectory)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        performSegue(withIdentifier: "TestToHomeSegue", sender: nil)
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Get a reference of this VC so we can refresh its charts
        if segue.identifier == "chartsSegue"{
            let destination = segue.destination as! ChartsViewController
            self.chartsVC = destination
        }
    }
}





extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
