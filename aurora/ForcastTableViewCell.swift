//
//  ForcastTableViewCell.swift
//  aurora
//
//  Created by Aaron on 22/5/2017.
//  Copyright © 2017 sightcorner. All rights reserved.
//

import Foundation
import UIKit

class ForcastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var possibility: UILabel!
    
    
    
    func prepare(country: String, possibility: String) {
        self.countryLabel.text = country
        self.possibility.text = possibility
    }
}
