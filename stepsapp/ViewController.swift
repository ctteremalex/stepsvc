//
//  ViewController.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 28.04.2021.
//

import UIKit

fileprivate let MinimalStepWidth: CGFloat = 80

class ViewController: UIViewController, CCStepsBarDataSource {
    
    private var stepsList = [CCStep]()
    private var stepsViewController: CCStepsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = UIViewController()
        vc1.view.backgroundColor = .green
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc1))

        let vc2 = UIViewController()
        vc1.view.backgroundColor = .red
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc2))

        let vc3 = UIViewController()
        vc1.view.backgroundColor = .yellow
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc3))

        let vc4 = UIViewController()
        vc1.view.backgroundColor = .blue
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc4))

        stepsViewController = CCStepsViewController(stepsBarDataSource: self)
        guard let stepsViewController = stepsViewController else {
            return
        }
        stepsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(stepsViewController)
        view.addSubview(stepsViewController.view)
        NSLayoutConstraint.activate([
            stepsViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stepsViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stepsViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stepsViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    func numberOfSteps() -> Int {
        return stepsList.count
    }
    
    func stepAtIndex(index: Int) -> CCStep {
        return stepsList[index]
    }
    
    func stepBarIndicator(index: Int) -> UIView {
        let newLabel = UILabel(frame: .zero)
        
        newLabel.textAlignment = .center
        newLabel.backgroundColor = .green
        newLabel.text = "Step-\(index)"

        return newLabel
    }
    
}
