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
    
    func didSelected(step: Int)
}

/// Provides events which are happened inside stepsbar
public protocol CCStepsBarDelegate: AnyObject {
    
    /// Check the completion of all steps
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

/// Stepsbar showing all the steps which user can choose
public class CCStepsBarView: UICollectionView {
    
    private enum JumpType {
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
    
    private var currentStepIndex: Int = 0
    
    /// Source of data for CCStepsBarView
    public weak var stepsDataSource: CCStepsBarDataSource?
    
    /// Provides events which are happened inside stepsbar
    public weak var stepsDelegate: CCStepsBarDelegate?
        
    /// Fully reloads all the layout of stepsbar
    public func reloadAllData(initial: Int) {
        if !checkStepsNumber() {
            return
        }
        
        dataSource = stepsDataSource
        delegate = self
        showsHorizontalScrollIndicator = false

        currentStepIndex = initial
    }
    
    /// Reload data and select the current index
    public func reloadForCurrentIndex() {
        reloadData() /// after reloading, select current step again
        initialSelectStep(index: currentStepIndex)
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
            selectCell(at: step, andDeselect: currentStepIndex)
            
            currentStepIndex = step
        case .jumpTo(step: let step):
            guard dataSource.canJumpTo(step: step) else {
                stepsDelegate.showIncompletionError(step: currentStepIndex)
                return
            }
            
            selectCell(at: step, andDeselect: currentStepIndex)
            
            currentStepIndex = step
            
        case .selectFromCell(let step):
            currentStepIndex = step
        }
        
        stepsDelegate.stepSelected(index: currentStepIndex)
        performBatchUpdates(nil, completion: nil)
    }
    
    private func selectCell(at index: Int, andDeselect oldIndex: Int) {
        let old = IndexPath(row: oldIndex, section: 0)
        let new = IndexPath(row: index, section: 0)
        deselectItem(at: old, animated: true)
        selectItem(at: new, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func initialSelection(step: Int) {
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

extension CCStepsBarView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat
        let cell = collectionView.cellForItem(at: indexPath)
        if cell?.isSelected == true {
            width = stepsDataSource?.selectedStepWidthAtIndex(index: indexPath.item) ?? 0
        } else {
            width = stepsDataSource?.minimalStepWidthAtIndex(index: indexPath.item) ?? 0
        }
        
        return .init(width: width, height: collectionView.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.performBatchUpdates(nil, completion: nil)
        activateStepAtIndex(index: .selectFromCell(indexPath.item))
        
    }
}
