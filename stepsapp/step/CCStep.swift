//
//  CCStep.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 29.04.2021.
//

import UIKit

public typealias StepSelectionHandler = () -> Void

public protocol StepViewControllerDelegate: UIViewController {
    var stepIsReady: Bool { get }
    
    func showIncompleteError()
}


/// Model of step for CCStepsViewController
public struct CCStep {
    public enum Position {
        case left
        case right
        case middle
    }
    
    public struct Width {
        let minimum: CGFloat
        let value: CGFloat
    }
    
    public var position: Position
    public var stepLabelWidth: Width = .init(minimum: 0, value: 1)
    public var viewController: StepViewControllerDelegate
    public var selectionBlock: StepSelectionHandler?
    
    public var canJumpToStep: ((_ index: Int) -> Bool)
}
