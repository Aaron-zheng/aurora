//
//  PictureViewController.swift
//  aurora
//
//  Created by Aaron on 6/5/2017.
//  Copyright © 2017 sightcorner. All rights reserved.
//

import Foundation
import UIKit

class PictureViewController: UIViewController {
    
    @IBOutlet weak var northImageView: UIImageView!
    @IBOutlet weak var southImageView: UIImageView!
    
    override func viewDidLoad() {
        prepare()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBarViewController = self.parent as! TabBarViewController
        tabBarViewController.tabBarDelegate = self
    }
    
    func prepare() {
        setImage(imageView: northImageView, url: northLatestURL)
        setImage(imageView: southImageView, url: southLatestURL)
    }
}

extension PictureViewController: TabBarViewControllerDeletegate {
    func refreshData() {
        self.prepare()
    }
}
