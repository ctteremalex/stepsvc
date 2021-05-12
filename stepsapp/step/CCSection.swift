//
//  CCSection.swift
//  stepsapp
//
//  Created by Herman on 5/8/21.
//

import UIKit

public enum CCSectionType {
    case currentRecord
    case parentRecord
    case childRecords
}

public struct CCSection {
    var id: Int
    var color: UIColor = .blue
    var label: String = "Default"
    var type: CCSectionType = .currentRecord
    var rect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var xPos: CGFloat { rect.origin.x }
    var yPos: CGFloat { rect.origin.y }
    var width: CGFloat { rect.width }
    var height: CGFloat { rect.height }
    
    
//    func intersects(_ rect2: CCSection) -> Bool {
//
//        if rect.origin.x >= rect2.xPos + rect2.width || rect2.xPos >= rect.origin.x + rect.size.width {
//            return false
//        }
//
//        CGRect.intersects(<#T##self: CGRect##CGRect#>)
//
//        if rect.origin.y <= rect2.yPos + rect2.height || rect2.yPos <= rect.origin.y + rect.size.height {
//            return false
//        }
//
//        return true
//    }
}
