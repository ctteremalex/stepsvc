//
//  CCStepsBarView.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 29.04.2021.
//

import UIKit

public protocol CCStepsBarDataSource: AnyObject {
    
    func numberOfSteps() -> Int
    func minimalStepWidthAtIndex(index: Int) -> CGFloat
    func stepBarIndicator(index: Int) -> UIView
    
}

public protocol CCStepsBarDelegate: AnyObject {
    
    func stepSelected(index: Int)
    
}

fileprivate let shift: CGFloat = 5

public class CCStepsBarView: UIView {
    
    private var currentStepIndex: Int = 0
    
    public var stepEdgeInsets = UIEdgeInsets(top: shift, left: shift, bottom: -shift, right: -shift)
    public weak var stepsDataSource: CCStepsBarDataSource?
    public weak var stepsDelegate: CCStepsBarDelegate?
    
    public func reloadData() {
        if !checkStepsNumber() {
            return
        }
        
        guard let stepsDataSource = stepsDataSource else {
            return
        }
        
        subviews.forEach { stepbarSubView in
            stepbarSubView.removeFromSuperview()
        }
        
        let numberOfSteps = stepsDataSource.numberOfSteps()
        var lastContainer: UIView?
        var leadingConstraint = leadingAnchor
        for i in 0...numberOfSteps - 1 {            
            let stepContainerView = CCStepsBarContainerView(frame: .zero)
            stepContainerView.tapBlock = { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.activateStepAtIndex(index: i)
            }
            addSubview(stepContainerView)

            let indicatorView = stepsDataSource.stepBarIndicator(index: i)
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            stepContainerView.addSubview(indicatorView)

            let minimalStepWidth = stepsDataSource.minimalStepWidthAtIndex(index: i)
            if let lastContainer = lastContainer {
                leadingConstraint = lastContainer.trailingAnchor
            }
            NSLayoutConstraint.activate([
                indicatorView.topAnchor.constraint(equalTo: stepContainerView.topAnchor, constant: stepEdgeInsets.top),
                indicatorView.bottomAnchor.constraint(equalTo: stepContainerView.bottomAnchor, constant: stepEdgeInsets.bottom),
                indicatorView.leadingAnchor.constraint(equalTo: stepContainerView.leadingAnchor, constant: stepEdgeInsets.left),
                indicatorView.trailingAnchor.constraint(equalTo: stepContainerView.trailingAnchor, constant: stepEdgeInsets.right),

                stepContainerView.leadingAnchor.constraint(equalTo: leadingConstraint),
                stepContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: minimalStepWidth),
                stepContainerView.topAnchor.constraint(equalTo: topAnchor),
                stepContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
            lastContainer = stepContainerView
            
            if i == numberOfSteps - 1 {
                NSLayoutConstraint.activate([
                    stepContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
                ])
            }
        }
    }
    
    public func jumpToStepAtIndex(index: Int) {
        activateStepAtIndex(index: index)
    }
    
    public func jumpToNextStep() {
        if !checkStepsNumber() {
            return
        }
        
        guard let stepsDataSource = stepsDataSource else {
            return
        }
        
        let nextStepIndex = currentStepIndex + 1
        if nextStepIndex > stepsDataSource.numberOfSteps() {
            return
        }
        
        activateStepAtIndex(index: nextStepIndex)
    }
    
    public func jumpToPreviousStep() {
        let previousStepIndex = currentStepIndex - 1
        if previousStepIndex < 0 {
            return
        }
        
        activateStepAtIndex(index: previousStepIndex)
    }
    
    private func activateStepAtIndex(index: Int) {
        if !checkStepsNumber() {
            return
        }

        currentStepIndex = index
        
        guard let stepsDelegate = stepsDelegate else {
            return
        }
        
        stepsDelegate.stepSelected(index: currentStepIndex)
    }
    
    private func checkStepsNumber() -> Bool {
        guard let stepsDataSource = stepsDataSource else {
            return false
        }
        
        let numberOfSteps = stepsDataSource.numberOfSteps()
        if numberOfSteps < 1 {
            return false
        }
        
        return true
    }
    
}
