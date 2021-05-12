//
//  Randomizers.swift
//  stepsapp
//
//  Created by Herman on 5/12/21.
//

import UIKit

public class RandomColor {
    static func get() -> UIColor {
        let number = Int.random(in: 1...6)
        switch number {
        case 1:
            return UIColor.red
        case 2:
            return UIColor.blue
        case 3:
            return UIColor.green
        case 4:
            return UIColor.darkGray
        case 5:
            return UIColor.orange
        case 6:
            return UIColor.magenta
        default:
            return UIColor.yellow
        }
    }
}

public class RandomName {
    static func get() -> String {
        let number = Int.random(in: 1...6)
        switch number {
        case 1:
            return "Up"
        case 2:
            return "Down"
        case 3:
            return "Top"
        case 4:
            return "Bottom"
        case 5:
            return "Strange"
        case 6:
            return "Charm"
        default:
            return ""
        }
    }
}

public class RandomRect {
    static func get(maxX: Int, maxY: Int) -> CGRect {
        let x = Int.random(in: 0..<maxX)
        let y = Int.random(in: 0..<maxY)
        let width = Int.random(in: 1...3)
        let height = Int.random(in: 1...3)
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

public class RandomSection {
    static func get() -> CCSection {
        let id = Int.random(in: 1...100)
        let color = RandomColor.get()
        let label = RandomName.get()
        return CCSection(id: id, color: color, label: label, type: .currentRecord, rect: RandomRect.get(maxX: 6, maxY: 10))
    }
}
