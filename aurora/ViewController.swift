//
//  ViewController.swift
//  auroa
//
//  Created by Aaron on 17/12/2016.
//  Copyright © 2016 sightcorner. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var data = Array<Forcast>()
    var countrys = Array<Country>()
    var dataSourceForTableView = Array<Country>()
    var codeDict = Dictionary<String, String>()
    var loading: Bool = false
    
    fileprivate var currentNodeName: String!
    fileprivate var country: Country!
    fileprivate var tdIndex: Int! = 0
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBarViewController = self.parent as! TabBarViewController
        tabBarViewController.tabBarDelegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    
    private func readCode() {
        
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil {
            
            do {
                let text = try String(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "code", ofType: "txt")!), encoding: String.Encoding.utf8)
                
                let lines = text.components(separatedBy: "\n")
                for line in lines {
                    if line.lengthOfBytes(using: .utf8) <= 0 {
                        continue
                    }
                    let nameAndCode = line.components(separatedBy: "\t")
                    codeDict[nameAndCode[1]] = nameAndCode[0]
                }
                
            } catch {
                print("Error info: \(error)")
            }
            
            
        }
    }
    
    func setupData() {
        readCode()
        let xmlParser = XMLParser(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "data", ofType: "xml")!))
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        requestAuroa()
        
        self.view.backgroundColor = UIColor.white
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
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

    private func getCurrent() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return hour.description + " " + minute.description + " " + second.description
    }
    
    func requestAuroa(isDisplay: Bool = false) {
        
        if loading {
            return
        }
        
        loading = true
        
        self.dataSourceForTableView.removeAll()
        self.tableView.reloadData()
        
        
        Alamofire.request(auroaURL).validate().response { (response) in
    
            
            if response.error == nil {
                self.performSuccessHandling(data: response.data)
            } else {
                self.performUnsuccessHandling()
            }
    
            self.cal()
            
            
            for each in self.countrys {
                
                let possibility = self.getPosibilityOfAurora(latitude: NSDecimalNumber.init(string: each.latitude), longitude: NSDecimalNumber.init(string: each.longitude))
                if !isDisplay {
                    let p = NSDecimalNumber.init(string: possibility)
                    if p.compare(0).rawValue <= 0{
                        continue
                    }
                }
                each.possibility = possibility
                if let chineseName = self.codeDict[each.code] {
                    each.name = chineseName
                }
                
                self.dataSourceForTableView.append(each)
            }
            
            
            
            self.dataSourceForTableView.sort(by: { (c1, c2) -> Bool in
                return Int.init(c1.possibility)! > Int.init(c2.possibility)!
            })
            
            
            self.tableView.reloadData()
            
            DispatchQueue.main.async {
            
                self.loading = false
            }
        }
    }
    
    func performSuccessHandling(data: Data?) {
        if let data = data {
            let html = String(data: data, encoding: String.Encoding.utf8)!
            parseHtml(html: html)
        }
    }
    
    
    func getPosibilityOfAurora(latitude: NSDecimalNumber, longitude: NSDecimalNumber) -> String{
        var result: Forcast!
        for each in data {
            if each.latitude.compare(latitude) == ComparisonResult.orderedAscending {
                result = each
            } else {
                break
            }
        }
        
        let longitudes = matches(for: "([0-9]+)", in: result.longitudes)
        var possibility: String! = ""
        let per = NSDecimalNumber.init(value: 360).dividing(by: NSDecimalNumber.init(value: longitudes.count))
        var calculatedLongitude: NSDecimalNumber!
        for i in 1 ... longitudes.count {
            calculatedLongitude = NSDecimalNumber.init(value: i).multiplying(by: per).subtracting(NSDecimalNumber.init(value: 180))
            
            if calculatedLongitude.compare(longitude) == ComparisonResult.orderedAscending {
                possibility = longitudes[i-1]
            } else {
                break
            }
        }
        
        return possibility
    }
    
    
    func performUnsuccessHandling() {
        
    }
    
    func cal() {
        var result: NSDecimalNumber = 0
        var lat: NSDecimalNumber = 0
        var log: NSDecimalNumber = 0
        for each in data {
            let longitudes = matches(for: "([0-9]+)", in: each.longitudes)
            for i in 1 ... longitudes.count {
                if result.compare(NSDecimalNumber.init(string: longitudes[i-1].trimmingCharacters(in: .whitespacesAndNewlines))) == ComparisonResult.orderedAscending {
                    
                    lat = each.latitude
                    log = NSDecimalNumber.init(value: 0.3515625).multiplying(by: NSDecimalNumber.init(value: (i - 1))).subtracting(NSDecimalNumber.init(value: 180))
                    
                    result = NSDecimalNumber.init(string: longitudes[i-1].trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
        let possibility = Int(truncating: result)
        let country = Country()
        country.name = "坐标 (" + lat.description + ", " + log.description + ")"
        country.possibility = possibility.description
        self.dataSourceForTableView.append(country)
        print("max: " + possibility.description + " " + lat.description + " " + log.description)
    }
    
    
    //1024 values covering 0 to 360 degrees in the horizontal (longitude) direction  (0.32846715 degrees/value)
    //512 values covering -90 to 90 degrees in the vertical (latitude) direction  (0.3515625 degrees/value)
    //Values range from 0 (little or no probability of visible aurora) to 100 (high probability of visible aurora)
    func parseHtml(html: String) {
        
        
        let array = html.components(separatedBy: "\n")
        var count = 0
        for each in array {
            if each.range(of: "#") == nil {
                
                let longtitude = each.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if longtitude.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                
                    count = count + 1
                    data.append(Forcast(count, longtitude))
                }
                
            }
        }
    }
    
    class Forcast {
        //start from 1~512, total 512
        var latitudeIndex: Int! = 0
        var latitude: NSDecimalNumber! = 0
        var longitudes: String! = ""
        
        init(_ latitudeIndex: Int, _ longitudes: String) {
            self.latitudeIndex = latitudeIndex
            self.longitudes = longitudes
            self.latitude = NSDecimalNumber.init(value: latitudeIndex).multiplying(by: NSDecimalNumber.init(value: 0.3515625)).subtracting(NSDecimalNumber.init(value: 90))
        }
    }
    
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
        
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 32))
        let leftLabel  = UILabel.init(frame: CGRect.init(x: 16, y: 0, width: self.tableView.frame.size.width, height: 32))
        let rightLabel  = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width - 16, height: 32))
        
        
        leftLabel.textAlignment = .left
        leftLabel.numberOfLines = 0
        rightLabel.textAlignment = .right
        rightLabel.numberOfLines = 0
        
        if self.dataSourceForTableView.count <= 1 {
            leftLabel.text = "数据加载中..."
            rightLabel.text = ""
        } else {
            leftLabel.text = "地理坐标(实时5分钟)"
            rightLabel.text = "极光概率"
        }
        headerView.backgroundColor = greyColor
        headerView.addSubview(leftLabel)
        headerView.addSubview(rightLabel)
        
        return headerView
    }
    
    
}

extension ViewController: UITableViewDataSource {
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceForTableView.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "forcastTableViewCell", for: indexPath) as! ForcastTableViewCell
        cell.prepare(country: dataSourceForTableView[indexPath.row].name,
                     possibility: dataSourceForTableView[indexPath.row].possibility + "%")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension ViewController: XMLParserDelegate {
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentNodeName = elementName
        if currentNodeName == "tr" {
            country = Country()
            tdIndex = 0
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "tr" {
            countrys.append(country)
            tdIndex = 0
        }
        
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let str = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if str.isEmpty {
            return
        }
        
        switch currentNodeName {
        case "td":
            tdIndex = tdIndex + 1
            if tdIndex == 1 {
                country.code = str
            } else if tdIndex == 2 {
                country.latitude = str
            } else if tdIndex == 3 {
                country.longitude = str
            } else if tdIndex >= 4 {
                country.name = country.name + str
            }
        default:
            break
        }
    }
}

extension ViewController: TabBarViewControllerDeletegate {
    func refreshData() {
        self.requestAuroa(isDisplay: true)
    }
}
