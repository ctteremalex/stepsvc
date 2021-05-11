//
//  CCStepsBarView.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 29.04.2021.
//

import UIKit

/// Source of data for CCStepsBarView
public protocol CCStepsBarDataSource: UICollectionViewDataSource {
    
    /// Number of steps to display in bar
    var numberOfSteps: Int { get }
    
    /// Minimal width for step container in bar
    /// - Parameter index: index of step for which we are looking for width
    func minimalStepWidthAtIndex(index: Int) -> CGFloat
    
//    /// UIView which will be placed on bar as step indicator
//    /// - Parameter index: index of step
//    func stepBarIndicator(index: Int) -> UIView
//    
//    /// UIView which will be placed on bar as active step indicator
//    /// - Parameter index: index of step
//    func stepBarActiveIndicator(index: Int) -> UIView
    
    ///
    func canJumpTo(step: Int) -> Bool
}

/// Provides events which are happeneed inside stepsbar
public protocol CCStepsBarDelegate: AnyObject {
    
    var allStepsCompleted: Bool { get }
    
    /// Step with index was selected
    /// - Parameter index: index of step
    func stepSelected(index: Int)

    /// Show an error for index
    /// - Parameter step: index of step
    func showIncompletionError(step: Int)
}

fileprivate let shift: CGFloat = 5

/// Stepsbar showing all the steps which user can choose
public class CCStepsBarView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var commonW: CGFloat = Constants.commonStepWidth
    private var selectedW: CGFloat = Constants.selectedStepWidth
    
    private enum Constants {
        static let stepHeight: CGFloat = 44
        static let selectedStepWidth: CGFloat = 200
        static let commonStepWidth: CGFloat = 100
        static let shift: CGFloat = 5
    }
    
    var widths: [CGFloat] = []
        
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        indexPath.section == 0
    }
        
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = widths[indexPath.item]
        return .init(width: width, height: Constants.stepHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        widths[indexPath.item] = commonW
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        widths[indexPath.item] = selectedW
        collectionView.performBatchUpdates(nil, completion: nil)
        jumpToStepAtIndex(index: indexPath.item)
    }
    
    private var currentStepIndex: Int = 0
    
    public var stepEdgeInsets = UIEdgeInsets(withInset: Constants.shift)
    public weak var stepsDataSource: CCStepsBarDataSource?
    public weak var stepsDelegate: CCStepsBarDelegate?
    
    /// Fully reloads all the layout of stepsbar
    public func reloadAllData() {
        if !checkStepsNumber() {
            return
        }
        
        dataSource = stepsDataSource
        delegate = self
        let stepNib = UINib(nibName: "CCStepCell", bundle: nil)
        register(stepNib, forCellWithReuseIdentifier: "step")
        reloadData()
        let count = collectionViewLayout.collectionView?.numberOfItems(inSection: 0) ?? 0
        let spacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        let sumOfSpacing = spacing * max(0, CGFloat(count) - 1)
        let width = ((superview?.frame.width ?? frame.width) -  sumOfSpacing) / (CGFloat(count) + 1)
        commonW = width
        selectedW = width * 2
        widths = .init(repeating: commonW, count: count)
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
        
        guard let dataSource = stepsDataSource else {
            return
        }
        
        if currentStepIndex < index {
            guard dataSource.canJumpTo(step: currentStepIndex) else {
                print("show Error: step \(currentStepIndex) is not completed")
                stepsDelegate.showIncompletionError(step: currentStepIndex)
                return
            }
        }
        
        widths[index] = selectedW
        selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        
        currentStepIndex = index
        
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

private extension UIView {
    func fillWith(subview: UIView, insets: UIEdgeInsets, and widthConstraint: NSLayoutConstraint) {
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right),
            widthConstraint,
        ])
    }
}

private extension UIEdgeInsets {
    init(withInset: CGFloat) {
        let inset = withInset
        self = .init(top: inset, left: inset, bottom: -inset, right: -inset)
    }
}
