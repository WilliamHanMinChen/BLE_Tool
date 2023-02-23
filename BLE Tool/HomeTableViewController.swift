//
//  HomeTableViewController.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/5.
//

import UIKit
import CoreLocation
import CoreBluetooth

class HomeTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    //Bluetooth manager
    var bluetoothManager: CBCentralManager = CBCentralManager()
    
    //Location manager
    var locationManager: CLLocationManager = CLLocationManager()
    
    //The list of UUIDs that we are looking for along with their brand name
    var beaconTypes: [String : String] = ["AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA" : "RF-STAR",
                                          "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB" : "BeeLink",
                                          "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC" : "Radioland",
                                          "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD" : "MokoSmart",
                                          "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE" : "EasywPhy"]
    
    //Buttons references
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var ManageButton: UIBarButtonItem!
    

    
    
    //Array to hold the beacons we have already discovered in our last couple of scans
    var foundBeacons: [CLBeacon] = []
    
    //Array to keep track of the beacons we are going to display based on the options parameters
    var displayBeacons: [CLBeacon] = []
    
    //Haptic generator
    var generator = UIImpactFeedbackGenerator(style: .medium)
    
    
    //Options variables
    //Sort by
    var sortBy : SortBy = .None
    var sortByType : SortBytype = .None
    //Filter by UUID (Type)
    var filterUUID : String?
    
    //Filter By Major and Minor
    var majorFilter : Int =  -1
    var minorFilter : Int = -1
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Request Location Usage
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        //Check if the user has granted permission
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .denied: //If the user had denied it
                
                //Give them an alert
                let alert = UIAlertController(title: "Alert", message: "Location access has been disabled, please enable it in the settings app",preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Take me there", style: UIAlertAction.Style.default, handler: { _ in
                    //Get the settings app's URL
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    //If we can open it
                    if UIApplication.shared.canOpenURL(settingsURL) {
                        UIApplication.shared.open(settingsURL, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                    
                }))
                
                //Present this alert message
                self.present(alert, animated: true, completion: nil)
                
            case .authorizedWhenInUse, .authorizedAlways:
                print("accepted")
            default:
                print("Other case")
                
            }
            
        }
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //Stop polling nearby BLEs
        for beaconType in beaconTypes {
            //Get UUID
            guard let uuid = UUID(uuidString: beaconType.0) else {
                fatalError("Failed to cast to UUID, check if UUID is entered correctly!")
            }
            
            let constraint = CLBeaconIdentityConstraint(uuid: uuid)
            
            locationManager.stopRangingBeacons(satisfying: constraint)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region")
    }
    
    //MARK: - Beacon methods
    //Called when one or more beacons satifying the constraints have been detected
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        
        //Update our class's beacons list (but dont add them in duplicate)
        for beacon in beacons{
            
            for foundBeacon in foundBeacons {
                //If it is the same
                if beacon.uuid == foundBeacon.uuid && beacon.major == foundBeacon.major && beacon.minor == foundBeacon.minor {
                    
                    let index = foundBeacons.firstIndex(of: foundBeacon)
                    foundBeacons.remove(at: index!)
                    
                }
            }
            self.foundBeacons.append(beacon)
            
        }
        
        //Check if there are beacons in our list that are not being scanned anymore
        for foundBeacon in foundBeacons {
            //If the beacon has the same beacon uuid as our current list of scanned beacons
            if foundBeacon.uuid == beaconConstraint.uuid {
                //Check if it is still visible
                var visible = false
                for beacon in beacons {
                    if beacon.major == foundBeacon.major && beacon.minor == foundBeacon.minor {
                        visible = true
                    }
                }
                
                //If not visible, remove it
                
                if !visible{
                    let index = foundBeacons.firstIndex(of: foundBeacon)
                    foundBeacons.remove(at: index!)
                }
                
            }
        }
        
        //Reload the data
        UpdateDisplayBeaconsList()
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Called view will appear")
        
        //Start ranging all beacon types
        for beaconType in beaconTypes {
            //Get UUID
            guard let uuid = UUID(uuidString: beaconType.0) else {
                fatalError("Failed to cast to UUID, check if UUID is entered correctly!")
            }
            
            let constraint = CLBeaconIdentityConstraint(uuid: uuid)
            
            locationManager.startRangingBeacons(satisfying: constraint)
            
        }
        
        //Update our list and reload the data
        UpdateDisplayBeaconsList()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.displayBeacons.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "beaconCell", for: indexPath) as! BeaconTableViewCell
        
        let beacon = displayBeacons[indexPath.section]
        
        
        
        let distance = String(format: "%.2f", beacon.accuracy)
        
        cell.brandNameLabel.text = beaconTypes[beacon.uuid.uuidString]
        
        cell.majorMinorLabel.text = "Major: \(beacon.major) Minor: \(beacon.minor)"
        
        cell.RSSILabel.text = "RSSI: \(beacon.rssi)"
        
        cell.distanceLabel.text = "Distance: \(distance)m"
        
        return cell
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Get the beacon that the user tapped
        let selectedBeacon = displayBeacons[indexPath.section]
        
        performSegue(withIdentifier: "HomeBeaconSegue", sender: selectedBeacon)
        
    }
    
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "beaconCell", for: indexPath) as! BeaconTableViewCell
//
//        let beacon = beacons[indexPath.section]
//        cell.majorMinorLabel.text = beacon.uuid.description
//        return cell
//    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Button callbacks
    @IBAction func optionsAction(_ sender: Any) {
        self.performSegue(withIdentifier: "homeOptionsSegue", sender: nil)
        
    }
    
    @IBAction func manageAction(_ sender: Any) {
        
    }
    
    

    //This function updates the list of beacons that should be displayed based on the options
    func UpdateDisplayBeaconsList(){
        
        //Reset our display list
        displayBeacons = []
        
        //If we have a UUID Filter, filter the beacons
        if let filterUUID = filterUUID {
            for beacon in foundBeacons {
                //Only add if beacon's uuid is our filter UUID
                if beacon.uuid.uuidString == filterUUID {
                    displayBeacons.append(beacon)
                }
            }
        } else {
            //We dont have one, include all beacons
            displayBeacons = foundBeacons
        }
        
        //Check for major and minor filters
        
        if majorFilter != -1 {
            
            for beacon in displayBeacons {
                //If it is the not the major we are looking for
                if beacon.major.intValue != majorFilter {
                    //Remove it
                    let index = displayBeacons.firstIndex(of: beacon)!
                    displayBeacons.remove(at: index)
                }
            }
        }
        
        if minorFilter != -1 {
            
            for beacon in displayBeacons {
                //If it is the not the major we are looking for
                if beacon.minor.intValue != minorFilter {
                    //Remove it
                    let index = displayBeacons.firstIndex(of: beacon)!
                    displayBeacons.remove(at: index)
                }
            }
        }
        
        //TODO: Make this not spaghetti code!!!!!!!!
        //Sort them
        
        if sortBy == .Distance {
            if sortByType == .Ascending {
                displayBeacons = displayBeacons.sorted(by: { $0.accuracy < $1.accuracy})
            } else {
                displayBeacons = displayBeacons.sorted(by: { $0.accuracy > $1.accuracy})
            }
        }
        
        if sortBy == .Minor {
            if sortByType == .Ascending {
                displayBeacons = displayBeacons.sorted(by: { $0.minor.intValue < $1.minor.intValue})
            } else {
                displayBeacons = displayBeacons.sorted(by: { $0.minor.intValue > $1.minor.intValue})
            }
        }
        
        if sortBy == .Major {
            if sortByType == .Ascending {
                displayBeacons = displayBeacons.sorted(by: { $0.major.intValue < $1.major.intValue})
            } else {
                displayBeacons = displayBeacons.sorted(by: { $0.major.intValue > $1.major.intValue})
            }
        }
        
        if sortBy == .RSSI {
            if sortByType == .Ascending {
                displayBeacons = displayBeacons.sorted(by: { $0.rssi < $1.rssi})
            } else {
                displayBeacons = displayBeacons.sorted(by: { $0.rssi > $1.rssi})
            }
        }
        
        
        
        
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeOptionsSegue" {
            //Give our next VC our beacon types
            let destination = segue.destination as! OptionsViewController
            
            
            //Update the values
            destination.beaconTypes = self.beaconTypes
            destination.sortBy = self.sortBy
            destination.sortByType = self.sortByType
            destination.filterUUID = self.filterUUID
            destination.majorFilter = self.majorFilter
            destination.minorFilter = self.minorFilter
            
            //Set the delegate
            destination.delegate = self
        }
        
        //Give the next VC the selected beacon's details
        if segue.identifier == "HomeBeaconSegue" {
            let destination = segue.destination as! BeaconDetailsViewController
            
            let beacon = sender as! CLBeacon
            
            destination.beacon = beacon
            
            let stringName = beaconTypes[beacon.uuid.uuidString]
            
            destination.beaconName = stringName
        }
    }
    
    //Delegate function
    
    func UpdateSettings(sortBy: SortBy, sortByType: SortBytype, filterUUID: String?, majorFilter: Int, minorFilter: Int){
        
        self.sortBy = sortBy
        self.sortByType = sortByType
        self.filterUUID = filterUUID
        self.majorFilter = majorFilter
        self.minorFilter = minorFilter
        
        
    }
    

}
