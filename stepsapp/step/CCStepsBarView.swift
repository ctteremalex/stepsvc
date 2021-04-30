//
//  CCStepsBarView.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 29.04.2021.
//

import UIKit

/// Source of data for CCStepsBarView
public protocol CCStepsBarDataSource: AnyObject {
    
    /// Number of steps to display in bar
    var numberOfSteps: Int { get }
    
    /// Minimal width for step container in bar
    /// - Parameter index: index of step for which we are looking for width
    func minimalStepWidthAtIndex(index: Int) -> CGFloat
    
    /// UIView which will be placed on bar as step indicator
    /// - Parameter index: index of step
    func stepBarIndicator(index: Int) -> UIView
    
}

/// Provides events which are happeneed inside stepsbar
public protocol CCStepsBarDelegate: AnyObject {
    
    var allStepsCompleted: Bool { get }
    
    /// Step with index was selected
    /// - Parameter index: index of step
    func stepSelected(index: Int)
    
    func isCompleted(step: Int) -> Bool
    
    func showIncompleteError(step: Int)
}

fileprivate let shift: CGFloat = 5

/// Stepsbar showing all the steps which user can choose
public class CCStepsBarView: UIStackView {
    private enum Constants {
        static let shift: CGFloat = 5
    }
    
    private var currentStepIndex: Int = 0
    
    public var stepEdgeInsets = UIEdgeInsets(withInset: Constants.shift)
    public weak var stepsDataSource: CCStepsBarDataSource?
    public weak var stepsDelegate: CCStepsBarDelegate?
    private var widthConstraints: [NSLayoutConstraint] = []
    
    /// Fully reloads all the layout of stepsbar
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
        
        for i in 0..<stepsDataSource.numberOfSteps {
            let stepContainerView = CCStepsBarContainerView(frame: .zero)
            stepContainerView.tapBlock = { [weak self] in
                guard let self = self else {
                    return
                }

                self.activateStepAtIndex(index: i)
            }
            addArrangedSubview(stepContainerView)

            let indicatorView = stepsDataSource.stepBarIndicator(index: i)
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            stepContainerView.addSubview(indicatorView)

            let minimalStepWidth = stepsDataSource.minimalStepWidthAtIndex(index: i)

            let widthConstraint = stepContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: minimalStepWidth)
            widthConstraints.append(widthConstraint)
            NSLayoutConstraint.activate([
                indicatorView.topAnchor.constraint(equalTo: stepContainerView.topAnchor, constant: stepEdgeInsets.top),
                indicatorView.bottomAnchor.constraint(equalTo: stepContainerView.bottomAnchor, constant: stepEdgeInsets.bottom),
                indicatorView.leadingAnchor.constraint(equalTo: stepContainerView.leadingAnchor, constant: stepEdgeInsets.left),
                indicatorView.trailingAnchor.constraint(equalTo: stepContainerView.trailingAnchor, constant: stepEdgeInsets.right),
                
                widthConstraint,
            ])
        }
    }
    
    /// Jump to step with exact index
    /// - Parameter index: index of step
    public func jumpToStepAtIndex(index: Int) {
        activateStepAtIndex(index: index)
    }
    
    /// Check borders according to current step and if possible switch to the next one
    public func jumpToNextStep() {
        if !checkStepsNumber() {
            return
        }
        
        guard let stepsDataSource = stepsDataSource else {
            return
        }
        
        let nextStepIndex = currentStepIndex + 1
        if nextStepIndex > stepsDataSource.numberOfSteps {
            return
        }
        
        activateStepAtIndex(index: nextStepIndex)
    }
    
    /// Check borders and switch to previous step
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

        guard let stepsDelegate = stepsDelegate else {
            return
        }
        
        if currentStepIndex < index {
            guard stepsDelegate.isCompleted(step: currentStepIndex) else {
                print("show Error: step \(currentStepIndex) is not completed")
                stepsDelegate.showIncompleteError(step: currentStepIndex)
                return
            }
        }
        
        currentStepIndex = index
        
        UIView.animate(withDuration: 0.3) {
            self.widthConstraints[index].priority = .init(rawValue: 1)

            self.widthConstraints.forEach { constraint in
                constraint.priority = .required
            }
            
            self.layoutIfNeeded()
        }
        
        stepsDelegate.stepSelected(index: currentStepIndex)
    }
    
    private func checkStepsNumber() -> Bool {
        guard let stepsDataSource = stepsDataSource else {
            return false
        }
        
        let numberOfSteps = stepsDataSource.numberOfSteps
        if numberOfSteps < 1 {
            return false
        }
        
        return true
    }
    
}

private extension UIEdgeInsets {
    init(withInset: CGFloat) {
        let inset = withInset
        self = .init(top: inset, left: inset, bottom: -inset, right: -inset)
    }
}
