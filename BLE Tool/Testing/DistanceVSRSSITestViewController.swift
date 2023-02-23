//
//  DistanceVSRSSITestViewController.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/12.
//

import UIKit
import CoreLocation
import SwiftCSVExport

class DistanceVSRSSITestViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var testStatusLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var dataPointsLabel: UILabel!
    
    @IBOutlet weak var rssiLabel: UILabel!
    
    @IBOutlet weak var topButton: UIButton!
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    //Test Distances:
    //var testDistances: [Int] = [1,2,3,4,5,6,7,8,9,10]
    var testDistances: [Int] = [1,2,3]
    
    //The number of data points at each distance
    var dataPoints: Int = 5
    
    //An array of array of ints, each array corresponds to the test distance index
    var capturedDataPoints: [[Readings]] = []

    //Current test distance index
    var currentTestDistanceIndex: Int = 0
    
    //Location manager
    var locationManager: CLLocationManager = CLLocationManager()
    
    //The beacon that the user is running the test on
    var beacon: CLBeacon?
    
    var beaconName: String?
    
    //The Charts VC that we need to refresh
    var chartsVC : ChartsViewController?
    
    //FileName
    var savedFileName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        topButton.layer.cornerRadius = 10
        
        locationManager.delegate = self
        
        topButton.setTitle("Start", for: .normal)
        
        //Update the button and label text
        testStatusLabel.text = "\(testDistances[currentTestDistanceIndex])m test, press start to begin"
        topButton.setTitle("Start", for: .normal)
        
        doneButton.title = "Restart"
        
        //Reset progress bar
        progressBar.progress = 0.0
        
    }

    
    //Conducts a test for our current test index
    func conductTest(){
        //Update the button and label text
        testStatusLabel.text = "\(testDistances[currentTestDistanceIndex])m test conducting..."
        //Add an array
        capturedDataPoints.append([])
        //Reset progress bar
        progressBar.progress = 0.0
        //Hide the top label
        topButton.isHidden = true
        //Reset the RSSI and Data points label
        dataPointsLabel.text = "Datapoints: "
        rssiLabel.text = "RSSI: "
        //Rest our chart
        chartsVC?.refreshContent(capturedSignals: [])
        
        guard let beacon = beacon else {
            fatalError("No beacon set!")
        }
        
        //Start polling this beacon
        let constraint = CLBeaconIdentityConstraint(uuid: beacon.uuid, major: CLBeaconMajorValue(beacon.major.intValue), minor: CLBeaconMinorValue(beacon.minor.intValue))
        
        locationManager.startRangingBeacons(satisfying: constraint)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        //If the accuracy is -1 then we ignore it
        if beacons.first!.accuracy == -1 {
            return
        }
        
        
        //Update our RSSI label
        rssiLabel.text = "RSSI: \(beacons.first!.rssi.description)"
        //Create the reading and add it
        let reading = Readings(time: Date(), RSSI: beacons.first!.rssi)
        
        //Check if we have enough captured results
        if capturedDataPoints[currentTestDistanceIndex].count < dataPoints {
            capturedDataPoints[currentTestDistanceIndex].append(reading)
            
            //Update our other labels
            dataPointsLabel.text = "Datapoints: \(capturedDataPoints[currentTestDistanceIndex].count.description)"
            
            //Update our charts
            chartsVC?.refreshContent(capturedSignals: capturedDataPoints[currentTestDistanceIndex])
            
            //Calculate our average RSSI:
            var totalRSSI = 0
            for dataPoint in self.capturedDataPoints[currentTestDistanceIndex] {
                totalRSSI += dataPoint.RSSI
            }
            
            var averageRSSI = 0
            if totalRSSI != 0 {
                averageRSSI = totalRSSI/self.capturedDataPoints[currentTestDistanceIndex].count
            }
            
            self.rssiLabel.text = self.rssiLabel.text! + " Average: \(averageRSSI)"
            
            //Update our progress bar
            //progressBar.setProgress(Float(capturedDataPoints[currentTestDistanceIndex].count) / Float(dataPoints), animated: true)
            
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // set progressView to 0%, with animated set to false
                self.progressBar.setProgress(Float(self.capturedDataPoints[self.currentTestDistanceIndex].count) / Float(self.dataPoints), animated: false)
                // 10-second animation changing from 100% to 0%
                UIView.animate(withDuration: 1, delay: 0, options: [], animations: { [unowned self] in
                    self.progressBar.layoutIfNeeded()
                })
            }
            

            
        } else {
            guard let beacon = beacon else {
                fatalError("No beacon set!")
            }
            
            //Start polling this beacon
            let constraint = CLBeaconIdentityConstraint(uuid: beacon.uuid, major: CLBeaconMajorValue(beacon.major.intValue), minor: CLBeaconMinorValue(beacon.minor.intValue))
            
            //Stop ranging
            locationManager.stopRangingBeacons(satisfying: constraint)
            //We have captured enough, check if we have another test we can do
            if currentTestDistanceIndex < testDistances.count - 1 {
                //Update our labels and buttons
                testStatusLabel.text = "\(testDistances[currentTestDistanceIndex + 1])m test, press start to begin"
                topButton.isHidden = false
                topButton.setTitle("Start", for: .normal)
                progressBar.progress = 0.0
            } else {
                //Reached the end, update our button to be finished
                topButton.isHidden = false
                topButton.setTitle("Share results", for: .normal)
                doneButton.title = "Done"
                testStatusLabel.text = "All Tests finished"
                
                //Export the results
                testFinished()
            }
            //Increment our test index
            currentTestDistanceIndex += 1
            
        }
        

    }
    
    
    
    
    //MARK: Button Actions
    
    
    @IBAction func topButtonAction(_ sender: Any) {
        //If we have more tests to do
        if currentTestDistanceIndex < testDistances.count{
            //Start the test (again)
            conductTest()
        } else {
            //We finished, share the results
            print("Share results")
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
        
        var fileName = timeFormatted + "-" + "DistanceRSSI" + "-" + beaconName
        fileName += "-" + beacon.major.intValue.description + "-" + beacon.minor.intValue.description
        
        
        // Add dictionary into rows of CSV Array
        let data:NSMutableArray  = NSMutableArray()
        //Output to CSV
        
        
        //Loop through the number of data points we captured for each distance
        for i in 0...dataPoints - 1 {
            //Create data object
            let dataPointData: NSMutableDictionary = NSMutableDictionary()
            //Loop through the distances
            for j in 0...testDistances.count - 1 {
                dataPointData.setObject(capturedDataPoints[j][i].RSSI, forKey: "\(testDistances[j])m" as NSCopying);
            }
            data.add(dataPointData);
        }
        // Add fields into columns of CSV headers
        var header:[String] = []
        for testDistance in testDistances {
            header.append("\(testDistance)m")
        }
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
    
    
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        //If we have more tests to do
        if currentTestDistanceIndex < testDistances.count {
            //Restart and reset everything
            currentTestDistanceIndex = 0
            capturedDataPoints = []
            //Update our labels and buttons
            testStatusLabel.text = "\(testDistances[currentTestDistanceIndex])m test, press start to begin"
            topButton.isHidden = false
            topButton.setTitle("Start", for: .normal)
            //Reset the RSSI and Data points label
            dataPointsLabel.text = "Datapoints: "
            rssiLabel.text = "RSSI: "
            //Rest our chart
            chartsVC?.refreshContent(capturedSignals: [])
            doneButton.title = "Restart"
            
            progressBar.progress = 0.0
            guard let beacon = beacon else {
                fatalError("No beacon set!")
            }
            
            //Start polling this beacon
            let constraint = CLBeaconIdentityConstraint(uuid: beacon.uuid, major: CLBeaconMajorValue(beacon.major.intValue), minor: CLBeaconMinorValue(beacon.minor.intValue))
            
            //Stop ranging
            locationManager.stopRangingBeacons(satisfying: constraint)
        } else {
            //User tapped done, go back to home screen
            self.performSegue(withIdentifier: "testToHomeSegue", sender: nil)
        }
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Get a reference of this VC so we can refresh its charts
        if segue.identifier == "chartsSegue"{
            let destination = segue.destination as! ChartsViewController
            self.chartsVC = destination
        }
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
