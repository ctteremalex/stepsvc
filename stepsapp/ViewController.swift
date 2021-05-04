//
//  ViewController.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 28.04.2021.
//

import UIKit

fileprivate let MinimalStepWidth: CGFloat = 80

class ViewController: UIViewController, CCStepsDataSource {
    
    private var stepsList = [CCStep]()
//    private var stepsViewController: StepViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = StepViewController()
        vc1.view.backgroundColor = .green
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc1, selectionBlock: {
            print("selected step is 01 with GREEN")
        }, isReady: {
            vc1.stepIsReady
        }))

        let vc2 = StepViewController()
        vc2.view.backgroundColor = .red
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc2, selectionBlock: {
            print("selected step is 02 with RED")
        }, isReady: {
            vc2.stepIsReady
        }))

        let vc3 = StepViewController()
        vc3.view.backgroundColor = .yellow
        vc3.view.tag = 10 // TODO: just to test an incompletion
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc3, selectionBlock: {
            print("selected step is 03 with YELLOW")
        }, isReady: {
            vc3.stepIsReady
        }))

        let vc4 = StepViewController()
        vc4.view.backgroundColor = .blue
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc4, selectionBlock: {
            print("selected step is 04 with BLUE")
        }, isReady: {
            vc4.stepIsReady
        }))

        let controller = CCStepsViewController(stepsDataSource: self)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(controller)
        view.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    var numberOfSteps: Int {
        stepsList.count
    }
    
    func minimalStepWidthAtIndex(index: Int) -> CGFloat {
        stepsList[index].minimalStepLabelWidth
    }

    func stepBarIndicator(index: Int) -> UIView {
        let newLabel = UILabel(frame: .zero)
        
        newLabel.textAlignment = .center
        newLabel.backgroundColor = .green
        newLabel.text = "Step-0\(index + 1)"

        return newLabel
    }
    
    func stepAtIndex(index: Int) -> CCStep {
        stepsList[index]
    }
    
}
