//
//  UIViewController+RMSteps.swift
//  step
//
//  Created by Mihail Terekhov on 26.04.2021.
//

import UIKit

extension UIViewController {

    private static var StepsControllerAssociatedKey: UInt8 = 0
    private static var StepAssociatedKey: UInt8 = 0

    public func adaptToEdgeInsets(newInsets: UIEdgeInsets) {
    }

    public var stepsController: RMStepsController? {
        get {
            return objc_getAssociatedObject(self, &UIViewController.StepsControllerAssociatedKey) as? RMStepsController
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.StepsControllerAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var step: RMStep {
        get {
            guard let associatedStep = objc_getAssociatedObject(self, &UIViewController.StepAssociatedKey) as? RMStep else {
                let newStep = RMStep()
                assignStep(newStep: newStep)
                return newStep
            }
            
            return associatedStep
        }
        set {
            assignStep(newStep: newValue)
        }
    }
    
    private func assignStep(newStep: RMStep) {
        objc_setAssociatedObject(self, &UIViewController.StepAssociatedKey, newStep, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
}
