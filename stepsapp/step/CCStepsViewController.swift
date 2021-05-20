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
    
    /// Step content is ready to jump out
    func stepIsReadyAtIndex(_ index: Int) -> Bool
    
    /// Step title to show as tile name
    func stepTitleAtIndex(_ index: Int) -> String
    
    /// Call it to show an incompleteness error
    func showIncompleteError(_ index: Int)
}

public class CCStepsViewController: UIViewController, CCStepsBarDelegate {
    
    private enum Constants {
        static let initialIndex: Int = 1
        static let stepBarHeight: CGFloat = 44
    }
    
    /// Attach this function as Selector method to jump to next step
    @IBAction public func jumpToNext() {
        stepsbar.jumpToNextStep()
    }
    
    /// Attach this function as Selector method to jump to previous step
    @IBAction public func jumpToPrevious() {
        stepsbar.jumpToPreviousStep()
    }
        
    public var allStepsCompleted: Bool {
        guard let dataSource = dataSource else {
            return false
        }
        
        var completed = false
        
        for index in 0..<dataSource.numberOfSteps {
            completed = completed && dataSource.canJumpTo(step: index)
        }
        
        return completed
    }
    
    public func showIncompletionError(step: Int) {
        dataSource?.showIncompleteError(step)
    }
    
    private let stepsView = UIView()
    
    private lazy var layout: UICollectionViewLayout = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
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
    
    /// Invalidates content size, calculates new widths, lays out step cell sizes
    public func invalidateIntrinsicContentSize() {
        stepsbar.invalidateIntrinsicContentSize()
    }
    
    private func createLayout() {
        view.addSubview(stepsView)
        view.addSubview(stepsbar)
        
        stepsbar.snp.makeConstraints { maker in
            maker.top.equalTo(view)
            maker.height.equalTo(Constants.stepBarHeight)
            maker.leading.equalTo(view)
            maker.trailing.equalTo(view)
        }
        
        stepsView.snp.makeConstraints { maker in
            maker.top.equalTo(Constants.stepBarHeight)
            maker.bottom.equalTo(view)
            maker.leading.equalTo(view)
            maker.trailing.equalTo(view)
        }
        
        stepsbar.reloadAllData(initial: Constants.initialIndex)
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
        let controller = step.viewController
        
        addChild(controller)
        stepsView.addSubview(controller.view)
        
        // this line removes unexpected size constraints
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        stepsView.snp.makeConstraints { maker in
            maker.edges.equalTo(controller.view)
        }
    }
}
