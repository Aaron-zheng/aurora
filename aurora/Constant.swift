//
//  Constant.swift
//  auroa
//
//  Created by Aaron on 17/12/2016.
//  Copyright © 2016 sightcorner. All rights reserved.
//

import Foundation
import UIKit

public let redColor = UIColor(red: 237 / 255.0, green: 65 / 255.0, blue: 45 / 255.0, alpha: 1.0)
public let blueColor = UIColor(red: 62 / 255.0, green: 130 / 255.0, blue: 247 / 255.0, alpha: 1.0)
public let greenColor = UIColor(red: 45 / 255.0, green: 169 / 255.0, blue: 79 / 255.0, alpha: 1.0)
public let yellowColor = UIColor(red: 253 / 255.0, green: 189 / 255.0, blue: 0.0, alpha: 1.0)
public let greyColor = UIColor(red: 238 / 255.0, green: 238 / 255.0, blue: 238 / 255.0, alpha: 1.0)
public let darkColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)


public class UIVerticalAlignLabel: UILabel {
    
    enum VerticalAligment: Int {
        case VerticalAligmentTop = 0
        case VerticalAligmentMiddle = 1
        case VerticalAligmentBottom = 2
    }
    
    
    var verticalAligment: VerticalAligment = .VerticalAligmentTop {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /**
     顶部和左对齐的标签
     
     - parameter bounds:        <#bounds description#>
     - parameter numberOfLines: <#numberOfLines description#>
     
     - returns: <#return value description#>
     */
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        
        switch verticalAligment {
        case .VerticalAligmentTop:
            return CGRect.init(x: bounds.origin.x, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
        case .VerticalAligmentMiddle:
            return CGRect.init(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
        case .VerticalAligmentBottom:
            return CGRect.init(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
        }
    }
    
    public override func drawText(in rect: CGRect) {
        let r = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: r)
    }
}
