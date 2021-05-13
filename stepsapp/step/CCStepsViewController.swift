//
//  CCStepsViewController.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 29.04.2021.
//

import UIKit

public protocol CCStepsDataSource: CCStepsBarDataSource {
    
    /// `CCStep` for index
    func stepAtIndex(index: Int) -> CCStep
    
}

public class CCStepsViewController: UIViewController, CCStepsBarDelegate {
    
    /// Attach this function as Selector method to jump to next step
    @IBAction public func jumpToNext() {
        stepsbar.jumpToNextStep()
    }
    
    /// Attach this function as Selector method to jump to previous step
    @IBAction public func jumpToPrevious() {
        stepsbar.jumpToPreviousStep()
    }
        
    public var allStepsCompleted: Bool {
        guard let source = dataSource else {
            return false
        }
        
        var completed = false
        
        for index in 0..<source.numberOfSteps {
            completed = completed && source.canJumpTo(step: index)
        }
        
        return completed
    }
    
    public func showIncompletionError(step: Int) {
        dataSource?.stepAtIndex(index: step).viewController.showIncompleteError()
    }
    
    private let StepsbarHeight: CGFloat = 44
    
    private let stepsView = UIView(frame: .zero)
    
    private lazy var layout: UICollectionViewLayout = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private lazy var stepsbar = CCStepsBarView(frame: .zero, collectionViewLayout: layout)
    
    public weak var dataSource: CCStepsDataSource?

    convenience init(stepsDataSource: CCStepsDataSource?) {
        self.init()

        stepsbar.stepsDelegate = self
        stepsbar.backgroundColor = .white
        stepsbar.stepsDataSource = stepsDataSource
        stepsbar.isScrollEnabled = true
        dataSource = stepsDataSource
        stepsbar.dataSource = stepsDataSource
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        createLayout()
    }
    
    /// Config inner UICollectionView's parameters, register cells and and adjust content insets
    public func configCollection(callback: (_ collection: CCStepsBarView) -> Void) {
        callback(stepsbar)
    }
    
    private func createLayout() {
        stepsView.translatesAutoresizingMaskIntoConstraints = false
        stepsbar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stepsView)
        view.addSubview(stepsbar)
        NSLayoutConstraint.activate([
            stepsbar.topAnchor.constraint(equalTo: view.topAnchor),
            stepsbar.heightAnchor.constraint(equalToConstant: 44),
            stepsbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepsbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stepsView.topAnchor.constraint(equalTo: stepsbar.bottomAnchor),
            stepsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stepsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
                
        stepsbar.reloadAllData(initial: 1)
        stepsbar.initialSelectStep(index: 1)
    }

    public func stepSelected(index: Int) {
        guard let dataSource = dataSource else {
            return
        }
        hideCurrentStepViewController()
        let step = dataSource.stepAtIndex(index: index)
        showStepViewController(step: step)
        dataSource.didSelected(step: index)
    }
    
    private func hideCurrentStepViewController() {
        children.forEach { (subViewController) in
            subViewController.view.removeFromSuperview()
            subViewController.removeFromParent()
        }
    }
    
    private func showStepViewController(step: CCStep) {
        addChild(step.viewController)
        stepsView.addSubview(step.viewController.view)
        step.viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            step.viewController.view.topAnchor.constraint(equalTo: stepsView.topAnchor),
            step.viewController.view.bottomAnchor.constraint(equalTo: stepsView.bottomAnchor),
            step.viewController.view.leadingAnchor.constraint(equalTo: stepsView.leadingAnchor),
            step.viewController.view.trailingAnchor.constraint(equalTo: stepsView.trailingAnchor),
        ])
    }
}
