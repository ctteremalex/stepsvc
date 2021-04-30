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
 
    public var minimalStepLabelWidth: CGFloat = 60
    public var viewController: StepViewControllerDelegate
    public var selectionBlock: StepSelectionHandler?
    
}
