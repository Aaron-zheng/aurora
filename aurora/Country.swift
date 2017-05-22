//
//  Country.swift
//  aurora
//
//  Created by Aaron on 14/5/2017.
//  Copyright © 2017 sightcorner. All rights reserved.
//

import Foundation

class Country {
    
    var code: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var name: String = ""
    var possibility: String = ""
    
    
    func output() {
        print(code + " " + latitude + " " + longitude + " " + name + " " + possibility)
    }
}
