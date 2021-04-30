//
//  CCStepsViewController.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 29.04.2021.
//

import UIKit

public protocol CCStepsDataSource: CCStepsBarDataSource {

    func stepAtIndex(index: Int) -> CCStep
    
}

public class CCStepsViewController: UIViewController, CCStepsBarDelegate {
    
    private let StepsbarHeight: CGFloat = 44
    
    private let stepsView = UIView(frame: .zero)
    private let stepsbar = CCStepsBarView()
    public weak var dataSource: CCStepsDataSource?

    convenience init(stepsDataSource: CCStepsDataSource?) {
        self.init()

        stepsbar.stepsDelegate = self
        stepsbar.stepsDataSource = stepsDataSource
        dataSource = stepsDataSource
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        createLayout()
    }
    
    private func createLayout() {
        stepsView.translatesAutoresizingMaskIntoConstraints = false
        stepsbar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stepsView)
        view.addSubview(stepsbar)
        NSLayoutConstraint.activate([
            stepsbar.topAnchor.constraint(equalTo: view.topAnchor),
            stepsbar.heightAnchor.constraint(equalToConstant: StepsbarHeight),
            stepsbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepsbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stepsView.topAnchor.constraint(equalTo: stepsbar.bottomAnchor),
            stepsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stepsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        stepsbar.reloadData()
        stepsbar.jumpToStepAtIndex(index: 0)
    }

    public func stepSelected(index: Int) {
        guard let dataSource = dataSource else {
            return
        }
        hideCurrentStepViewController()
        let step = dataSource.stepAtIndex(index: index)
        showStepViewController(step: step)
        
        guard let stepSelectionBlock = step.selectionBlock else {
            return
        }
        stepSelectionBlock()
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
    
    private func changeStepsBar(step: CCStep) {
        
    }
    
}
