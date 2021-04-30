//
//  CCStep.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 29.04.2021.
//

import UIKit

public typealias StepSelectionHandler = () -> Void

/// Model of step for CCStepsViewController
public struct CCStep {
 
    public var minimalStepLabelWidth: CGFloat = 60
    public var viewController = UIViewController()
    public var selectionBlock: StepSelectionHandler?
    
}
