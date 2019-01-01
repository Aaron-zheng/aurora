//
//  TabBarViewController.swift
//  aurora
//
//  Created by Aaron on 1/1/2019.
//  Copyright © 2019 sightcorner. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {
    
    var tabBarDelegate: TabBarViewControllerDeletegate?
    
    @IBAction func refreshData(_ sender: Any) {
        if nil != self.tabBarDelegate {
            self.tabBarDelegate?.refreshData()
        }
    }
    
    override func viewDidLoad() {
        self.tabBar.tintColor = greenColor
        self.tabBar.barTintColor = greyColor
    }
}


protocol TabBarViewControllerDeletegate {
    func refreshData()
}
