//
//  BeaconTableViewCell.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/5.
//

import UIKit

class BeaconTableViewCell: UITableViewCell {

    @IBOutlet weak var majorMinorLabel: UILabel!
    
    @IBOutlet weak var brandNameLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var RSSILabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
