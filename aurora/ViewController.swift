//
//  ViewController.swift
//  auroa
//
//  Created by Aaron on 17/12/2016.
//  Copyright © 2016 sightcorner. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var forcastLabel: UIVerticalAlignLabel!
    
    private let auroaURL = "http://www.aurora-service.net/aurora-forecast/"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
        setupData()
        
    }
    
    func setup() {
        self.view.backgroundColor = greyColor
        
        
    }
    
    func setupData() {
        requestAuroa()
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(ViewController.requestAuroa), userInfo: nil, repeats: true)
    }
    
    private func blur(background: UIView) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = background.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        background.addSubview(blurEffectView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func changeBackground() {
        backgroundImageView.image = UIImage(named: "background" + arc4random_uniform(4).description)
    }
    
    func requestAuroa() {
        changeBackground()
        
        forcastLabel.text = "加载数据中..."
        
        Alamofire.request(auroaURL).validate().response { (response) in
            
            if response.error == nil {
                self.performSuccessHandling(data: response.data)
            } else {
                self.performUnsuccessHandling()
            }
        }
    }
    
    func performSuccessHandling(data: Data?) {
        if let data = data {
            let html = String(data: data, encoding: String.Encoding.utf8)!
            let forcastArray = parseHtml(html: html)
            var text: String = ""
            

            
            text = text + "实时的 极光预测值为：" + kpDescription(kp: forcastArray[0].kp) + "\n\n\n"
            
            
            text = text + "明天的 极光预测值为：" + kpDescription(kp: forcastArray[1].kp) + "\n\n"
            
            
            text = text + "后天的 极光预测值为：" + kpDescription(kp: forcastArray[2].kp) + "\n\n"
            
            
            
            
            forcastLabel.text = text
        }
    }
    
    func kpDescription(kp: Float) -> String{
        var description: String = "Kp " + kp.description
        
        if kp < 4 {
            description = description + "（低）"
        } else if kp > 5 {
            description = description + "（高）"
        } else {
            description = description + "（中）"
        }
        
        return description
    }
    
    func performUnsuccessHandling() {
        
    }
    
    func parseHtml(html: String) -> Array<Forcast> {
        let currentXPath = "//div[@class='transtab']//h4//span"
        //let minuteXPath = "//div[@class='transtab']//h5//span"
        let dayXPath = "//div[@class='transtab']//pre//p//strong"
        var forcastArray = Array<Forcast>()
        
        if let html = HTML(html: html, encoding: .utf8) {
            //current
            
            forcastArray.append(Forcast(kp: toFloat(str: html.xpath(currentXPath).first!.text!), time: 0, type: .minute))
            
            
            let str = html.xpath(dayXPath).first!.text!
            let array = str.components(separatedBy: "        ")
            
            
            forcastArray.append(Forcast(kp: toFloat(str: array[2]), time: toInt(str: "1"), type: .minute))
            forcastArray.append(Forcast(kp: toFloat(str: array[3]), time: toInt(str: "2"), type: .minute))
            
            //
            /*
            let minutePath = html.xpath(minuteXPath)
            forcastArray.append(Forcast(kp: toFloat(str: minutePath[1].text!), time: toInt(str: minutePath[0].text!), type: .minute))
            forcastArray.append(Forcast(kp: toFloat(str: minutePath[3].text!), time: toInt(str: minutePath[2].text!), type: .minute))
            forcastArray.append(Forcast(kp: toFloat(str: minutePath[5].text!), time: toInt(str: minutePath[4].text!), type: .minute))
            */
            
            
            for node in forcastArray {
                print(node.kp.description + " " + node.time.description)
            }
        }
        
        return forcastArray
    }
    
    func toFloat(str: String) -> Float {
        let tmp = str.lowercased().replacingOccurrences(of: "kp", with: "").replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespacesAndNewlines) as NSString
        return tmp.floatValue
    }
    func toInt(str: String) -> Int {
        let tmp = str.lowercased().replacingOccurrences(of: "kp", with: "").trimmingCharacters(in: .whitespacesAndNewlines) as NSString
        return tmp.integerValue
    }
}

class Forcast {
    var kp: Float! = 0
    var time: Int! = 0
    var type: ForcastType!
    
    init(kp: Float, time: Int, type: ForcastType) {
        self.kp = kp
        self.time = time
        self.type = type
    }
    
}

enum ForcastType {
    case minute
    case date
}
