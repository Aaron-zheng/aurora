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
            /*分享功能，先隐藏，等之后想好后再做*/
//            shareButtonHandler()
            
        }
    }
    
    override func viewDidLoad() {
        self.tabBar.tintColor = greenColor
        self.tabBar.barTintColor = greyColor
    }
    
    
    func getShareViewImage(v: UIView) -> UIImage {
        let w = v.frame.width
        let h = v.frame.height
        let size = CGSize(width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        v.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func shareButtonHandler() {
        let img = getShareViewImage(v: self.view)
        let ext = WXImageObject()
        ext.imageData = img.jpegData(compressionQuality: 1)
        
        let message = WXMediaMessage()
        message.title = nil
        message.description = nil
        message.mediaObject = ext
        message.mediaTagName = "极光预测"
        //生成缩略图
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 50))
        img.draw(in: CGRect(x: 0, y: 0, width: 100, height: 50))
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        message.thumbData = thumbImage!.pngData()
        
        let req = SendMessageToWXReq()
        req.text = nil
        req.message = message
        req.bText = false
        req.scene = 0
        WXApi.send(req)
    }
}


protocol TabBarViewControllerDeletegate {
    func refreshData()
}
