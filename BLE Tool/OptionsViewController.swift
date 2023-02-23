//
//  OptionsViewController.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/5.
//

import UIKit

class OptionsViewController: UIViewController {
    
    //The different types of beacons (for our drop down menu)
    var beaconTypes: [String : String] = [:]
    
    //Current Settings (From home screen)
    var sortBy : SortBy = .None
    var sortByType: SortBytype = .None
    //Filter by UUID (Type)
    var filterUUID : String?
    
    //Filter By Major and Minor
    var majorFilter : Int =  -1
    var minorFilter : Int = -1
    
    //Delegate Call Back
    var delegate: HomeTableViewController?
    
    
    //UI References
    @IBOutlet weak var typeMenu: UIButton!
    
    @IBOutlet weak var majorTextfield: UITextField!
    
    @IBOutlet weak var minorTextfield: UITextField!
    
    @IBOutlet weak var sortBySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var sortByTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //If our sort by is None, we hide the sort by type
        if sortBy == .None {
            sortByTypeSegmentedControl.isHidden = true
            sortByType = .None
        } else {
            sortBySegmentedControl.selectedSegmentIndex = sortBy.rawValue
            sortByType = .Ascending
            //Check for sort by type
            if sortByType == .Decending {
                sortByTypeSegmentedControl.selectedSegmentIndex = 1
            }
        }
        
        //Setup our button
        setUpTypeMenu()
        
        saveButton.layer.cornerRadius = 10
        
        typeMenu.layer.cornerRadius = 10
        
        //Update textfield
        
        if majorFilter != -1 {
            majorTextfield.text = String(majorFilter)
        }
        if minorFilter != -1 {
            minorTextfield.text = String(minorFilter)
        }
        
        
        //Resign keyboard
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    // MARK: - Button Actions
    
    @IBAction func sortBySegmentedControlChanged(_ sender: Any) {
        
        //If we moved off from none, unhide the other segmented control
        if sortBySegmentedControl.selectedSegmentIndex != 0 {
            sortByTypeSegmentedControl.isHidden = false
            sortByType = .Ascending
        } else{
            sortByTypeSegmentedControl.isHidden = true
            sortByType = .None
        }
        
        sortBy = SortBy(rawValue: sortBySegmentedControl.selectedSegmentIndex)!
    }
    
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        //Get our filters
        var majorFilter = -1
        if let major = majorTextfield.text, !major.isEmpty {
            majorFilter = Int(major) ?? -1
        }
        
        var minorFilter = -1
        if let minor = minorTextfield.text, !minor.isEmpty {
            minorFilter = Int(minor) ?? -1
        }
        
        
        delegate?.UpdateSettings(sortBy: sortBy, sortByType: sortByType, filterUUID: filterUUID, majorFilter: majorFilter, minorFilter: minorFilter)
        
        //Call delegate method
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sortByTypeSegmentedControlChanged(_ sender: Any) {
        
        sortByType = SortBytype(rawValue: sortByTypeSegmentedControl.selectedSegmentIndex)!
        
        
    }
    
    ///This function sets up the menu button
    func setUpTypeMenu(){
        
        //The handler for the tap
        let menuTapHandler = {(action: UIAction) in
            //If we selected none
            if action.title == "None" {
                //Reset filterUUID
                self.filterUUID = nil
            } else {
                //Find the right beacon type and update our filterUUID so it can be passed back to the home VC
                for beaconType in self.beaconTypes {
                    if beaconType.1 == action.title {
                        self.filterUUID = beaconType.0
                        print("Got here")
                    }
                }
            }
        }
        
        //The menu list
        var actionsList : [UIAction] = []
        
        //If we dont have a filtering UUID, let None be the sleected one
        if filterUUID == nil {
            actionsList.append(UIAction(title: "None", state: .on, handler: menuTapHandler))
        } else {
            actionsList.append(UIAction(title: "None", handler: menuTapHandler))
        }
        
        //Loop through our beacon list
        for beaconType in beaconTypes {
            //Check if we have a filterUUID, if so select that option
            if let filterUUID = filterUUID, beaconType.0 == filterUUID {
                actionsList.append(UIAction(title: beaconType.1, state: .on, handler: menuTapHandler))
            } else {
                actionsList.append(UIAction(title: beaconType.1, handler: menuTapHandler))
            }
        }
        
        typeMenu.menu = UIMenu(children: actionsList)
        typeMenu.showsMenuAsPrimaryAction = true
        typeMenu.changesSelectionAsPrimaryAction = true

        
    }
    
    
    //Resets the button states
    @IBAction func resetAction(_ sender: Any) {
        
        //Reset the menu
        self.filterUUID = nil
        setUpTypeMenu()
        
        majorTextfield.text = ""
        minorTextfield.text = ""
        
        sortBy = .None
        sortByType = .None
        
        sortBySegmentedControl.selectedSegmentIndex = 0
        sortByTypeSegmentedControl.selectedSegmentIndex = 0
        sortByTypeSegmentedControl.isHidden = true
        
        
        
        
        
        
    }
    
    
    
    
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    

}
