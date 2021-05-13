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
    
    /// Wider width for selected step container in bar
    /// - Parameter index: index of selected step for which we are looking for width
    func selectedStepWidthAtIndex(index: Int) -> CGFloat
    
    /// checking the step status
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
    
    /// Allows to jump next step by step
    func jumpToNext()
    
    /// Allows to jump next step by step
    func jumpToPrevious()
}

fileprivate let shift: CGFloat = 5

/// Stepsbar showing all the steps which user can choose
public class CCStepsBarView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    enum JumpType {
        case selectFromCell(Int)
        case initialValue(Int)
        case jumpTo(step: Int)
        
        var index: Int {
            switch self {
            case .initialValue(let step):
                return step
            case .selectFromCell(let step):
                return step
            case .jumpTo(let step):
                return step
            }
        }
    }
    
    private enum Constants {
        static let stepHeight: CGFloat = 44
        static let selectedStepWidth: CGFloat = 200
        static let commonStepWidth: CGFloat = 100
        static let shift: CGFloat = 5
    }
    
    var widths: [CGFloat] = []
        
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        true
    }
        
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = widths[indexPath.item]
        return .init(width: width, height: collectionView.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        widths[indexPath.item] = stepsDataSource!.minimalStepWidthAtIndex(index: indexPath.row)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        widths[indexPath.item] = stepsDataSource!.selectedStepWidthAtIndex(index: indexPath.row)
        collectionView.performBatchUpdates(nil, completion: nil)
        activateStepAtIndex(index: .selectFromCell(indexPath.item))
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
        showsHorizontalScrollIndicator = false

        let count = stepsDataSource?.numberOfSteps ?? 0
        widths = (0..<count).map { value in
            stepsDataSource?.minimalStepWidthAtIndex(index: value) ?? 0
        }
        
        
        
        initialSelection(step: 0)
    }
    
    /// Select a step with exact index
    /// - Parameter index: index of step
    public func initialSelectStep(index: Int) {
        activateStepAtIndex(index: .initialValue(index))
    }

    /// Jump to step with exact index
    /// - Parameter index: index of step
    public func jumpToStepAtIndex(index: Int) {
        activateStepAtIndex(index: .jumpTo(step: index))
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
        if nextStepIndex >= stepsDataSource.numberOfSteps {
            return
        }
        
        activateStepAtIndex(index: .jumpTo(step: nextStepIndex))
    }
    
    /// Check borders and switch to previous step
    public func jumpToPreviousStep() {
        let previousStepIndex = currentStepIndex - 1
        if previousStepIndex < 0 {
            return
        }
        
        activateStepAtIndex(index: .jumpTo(step: previousStepIndex))
    }
    
    private func activateStepAtIndex(index: JumpType) {
        if !checkStepsNumber() {
            return
        }

        guard let stepsDelegate = stepsDelegate else {
            return
        }
        
        guard let dataSource = stepsDataSource else {
            return
        }
        
        switch index {
        case .initialValue(let step):
            widths[step] = dataSource.minimalStepWidthAtIndex(index: step)
            selectCell(at: step, andDeselect: currentStepIndex)
            
            currentStepIndex = step
        case .jumpTo(step: let step):
            guard dataSource.canJumpTo(step: step) else {
                stepsDelegate.showIncompletionError(step: currentStepIndex)
                return
            }
            
            widths[step] = dataSource.minimalStepWidthAtIndex(index: step)
            selectCell(at: step, andDeselect: currentStepIndex)
            
            currentStepIndex = step
            
        case .selectFromCell(let step):
            currentStepIndex = step
        }
        
        stepsDelegate.stepSelected(index: currentStepIndex)
    }
    
    private func selectCell(at index: Int, andDeselect oldIndex: Int) {
        let old = IndexPath(row: oldIndex, section: 0)
        let new = IndexPath(row: index, section: 0)
        collectionView(self, didDeselectItemAt: old)
        collectionView(self, didSelectItemAt: new)
        selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func initialSelection(step: Int) {
        widths[step] = stepsDataSource!.selectedStepWidthAtIndex(index: step)
        selectItem(at: IndexPath(item: step, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        
        currentStepIndex = step
        
        stepsDelegate?.stepSelected(index: currentStepIndex)
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
