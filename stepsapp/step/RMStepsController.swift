//
//  RMStepsController.swift
//  step
//
//  Created by Mihail Terekhov on 26.04.2021.
//

import UIKit

public class RMStepsController: UIViewController, RMStepsBarDelegate, RMStepsBarDataSource {
    
    
    private let AnimationDuration: TimeInterval = 0.3

    private var currentStepViewController: UIViewController?
    private lazy var stepViewControllerContainer: UIView = {
        let newContainer = UIView(frame: .zero)
        newContainer.translatesAutoresizingMaskIntoConstraints = false
        return newContainer
    }()

    public private(set) lazy var stepsBar: RMStepsBar = {
        let newStepbar = RMStepsBar(frame: .zero)
        newStepbar.toolbardDelegate = self
        newStepbar.delegate = self
        newStepbar.dataSource = self
        return newStepbar
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stepViewControllerContainer)
        view.addSubview(stepsBar)

        let bindingsDict = [
            "stepsBar" : stepsBar,
            "container" : stepViewControllerContainer
        ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[stepsBar]", options: [], metrics: nil, views: bindingsDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[container]-(0)-|", options: [], metrics: nil, views: bindingsDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[stepsBar]-0-|", options: [], metrics: nil, views: bindingsDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[container]-0-|", options: [], metrics: nil, views: bindingsDict))
        
        let constraint = NSLayoutConstraint(item: stepsBar,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view.safeAreaLayoutGuide.topAnchor,
                                            attribute: .firstBaseline,
                                            multiplier: 1,
                                            constant: 44)
        view.addConstraint(constraint)
        
        loadStepViewControllers()
        if let firstViewController = children.first {
            showStepViewController(viewController: firstViewController, animated: false)
        }
    }
    
    private func loadStepViewControllers() {
        let stepViewControllersList = stepViewControllers()
        for viewController in stepViewControllersList {
            viewController.stepsController = self
            viewController.willMove(toParent: self)
            addChild(viewController)
            viewController.didMove(toParent: self)
        }
        
        stepsBar.reloadData()
    }
    
    private func showStepViewController(viewController: UIViewController, animated: Bool) {
        if !animated {
            showStepViewControllerWithoutAnimation(viewController: viewController)
        }
        else {
            showStepViewControllerWithSlideInAnimation(viewController: viewController)
        }
        
        updateContentInsetsForViewController(viewController: viewController)
    }
    
    private func updateContentInsetsForViewController(viewController: UIViewController) {
        if !extendViewControllerBelowBars(viewController: viewController) {
            return
        }
        
        var insets: UIEdgeInsets = .zero
        insets.top += stepsBar.frame.height
        viewController.adaptToEdgeInsets(newInsets: insets)
    }
    
    private func showStepViewControllerWithSlideInAnimation(viewController: UIViewController) {
        let oldIndex = currentStepIndex()
        guard let newIndex = children.firstIndex(of: viewController) else {
            return
        }
        
        var fromLeft = false
        if !(oldIndex < newIndex) {
            fromLeft = true
        }
        
        var y: CGFloat = 0
        if !extendViewControllerBelowBars(viewController: viewController) {
            y = stepsBar.frame.maxY
        }

        var x = stepViewControllerContainer.frame.width
        if fromLeft {
            x = -stepViewControllerContainer.frame.width
        }
        viewController.view.frame = CGRect(x: x,
                                           y: y,
                                           width: stepViewControllerContainer.frame.width,
                                           height: stepViewControllerContainer.frame.height - y)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.translatesAutoresizingMaskIntoConstraints = true
        stepViewControllerContainer.addSubview(viewController.view)
        
        if let index = children.firstIndex(of: viewController) {
            stepsBar.setupIndexOfSelectedStep(newIndexOfSelectedStep: index, animated: true)
        }
        
        UIView.animate(withDuration: AnimationDuration,
                       delay: 0,
                       options: .layoutSubviews,
                       animations: { [weak self] in
                        guard let self = self else {
                            return
                        }
                        
                        viewController.view.frame = CGRect(x: 0,
                                                           y: y,
                                                           width: self.stepViewControllerContainer.frame.width,
                                                           height: self.stepViewControllerContainer.frame.height - y)
                        var currentStepFrame = self.currentStepViewController?.view.frame
                        currentStepFrame?.origin.x = x
                        self.currentStepViewController?.view.frame = currentStepFrame ?? .zero
                        
                       },
                       completion: { [weak self] finished in
                        guard let self = self else {
                            return
                        }
                        
                        self.currentStepViewController?.view.removeFromSuperview()
                        self.currentStepViewController = viewController
                       })
    }

    private func showStepViewControllerWithoutAnimation(viewController: UIViewController) {
        if let currentStepViewController = currentStepViewController {
            currentStepViewController.view.removeFromSuperview()
        }
        
        var y: CGFloat = 0
        if !extendViewControllerBelowBars(viewController: viewController) {
            y = stepsBar.frame.maxY
        }
        viewController.view.frame = CGRect(x: 0, y: y, width: stepViewControllerContainer.frame.width, height: stepViewControllerContainer.frame.height)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.translatesAutoresizingMaskIntoConstraints = true
        
        stepViewControllerContainer.addSubview(viewController.view)
        currentStepViewController = viewController
        if let index = children.firstIndex(of: viewController) {
            stepsBar.setupIndexOfSelectedStep(newIndexOfSelectedStep: index)
        }
    }
    
    private func extendViewControllerBelowBars(viewController: UIViewController) -> Bool {
        return false
//        return (viewController.extendedLayoutIncludesOpaqueBars ||
//                    (viewController.edgesForExtendedLayout & UIRectEdge.top));
    }

    public func stepViewControllers() -> [RMStepsController] {
        return [RMStepsController]()
    }
    
    public func currentStepIndex() -> Int {
        guard let currentStepViewController = currentStepViewController else {
            return 0
        }
        if let index = children.firstIndex(of: currentStepViewController) {
            return index
        }
        
        return 0
    }
    
    public func showNextStep() {
        let index = currentStepIndex()
        if index < children.count - 1 {
            let viewController = children[index + 1]
            showStepViewController(viewController: viewController, animated: true)
        }
        else {
            finishedAllSteps()
        }
    }
    
    public func showStepForIndex(index: Int) {
        let viewController = children[index]
        showStepViewController(viewController: viewController, animated: true)
    }
    
    public func showPreviousStep() {
        let index = currentStepIndex()
        if index > 0 {
            let viewController = children[index - 1]
            showStepViewController(viewController: viewController, animated: true)
        }
        else {
            canceled()
        }
    }
    
    public func finishedAllSteps() {
        print("finished")
    }
    
    public func canceled() {
        print("canceled")
    }
    
    public func stepsBarDidSelectCancelButton(bar: RMStepsBar) {
        canceled()
    }
    
    public func stepsBar(bar: RMStepsBar, shouldSelectStepAtIndex: Int) {
        let viewController = children[shouldSelectStepAtIndex]
        showStepViewController(viewController: viewController, animated: true)
    }
    
    public func numberOfStepsInStepsBar(stepbar: RMStepsBar) -> Int {
        return children.count
    }
    
    public func stepsBar(stepbar: RMStepsBar, stepAtIndex: Int) -> RMStep {
        let viewController = children[stepAtIndex]
        return viewController.step
    }

}
