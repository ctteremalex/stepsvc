//
//  ViewController.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 28.04.2021.
//

import UIKit

fileprivate let MinimalStepWidth: CGFloat = 80

class StepViewController: UIViewController, StepViewControllerDelegate {
    var stepIsReady: Bool = false
    
    /// custom logic-UI to handle form in view ccontroller
    lazy var checkSwitch: UISwitch = {
        let switcher = UISwitch(frame: .init(origin: .zero, size: .init(width: 100, height: 100)))
        
        switcher.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switcher)
        NSLayoutConstraint.activate([
            switcher.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            switcher.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        switcher.addTarget(self, action: #selector(didChanged(on:)), for: .valueChanged)
        return switcher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkSwitch.isOn = false
    }
    
    @IBAction private func didChanged(on: Bool) {
        stepIsReady = checkSwitch.isOn
    }
    
    func showIncompleteError() {
        // TODO: do your error UI
        let currentColor = view.backgroundColor
        view.backgroundColor = .white

        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = currentColor
            self.view.layoutIfNeeded()
        }

    }
}

class ViewController: UIViewController, CCStepsDataSource {
    
    private var stepsList = [CCStep]()
//    private var stepsViewController: StepViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = StepViewController()
        vc1.view.backgroundColor = .green
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc1, selectionBlock: {
            print("selected step is 01 with GREEN")
        }))

        let vc2 = StepViewController()
        vc2.view.backgroundColor = .red
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc2, selectionBlock: {
            print("selected step is 02 with RED")
        }))

        let vc3 = StepViewController()
        vc3.view.backgroundColor = .yellow
        vc3.view.tag = 10 // TODO: just to test an incompletion
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc3, selectionBlock: {
            print("selected step is 03 with YELLOW")
        }))

        let vc4 = StepViewController()
        vc4.view.backgroundColor = .blue
        stepsList.append(CCStep(minimalStepLabelWidth: MinimalStepWidth, viewController: vc4, selectionBlock: {
            print("selected step is 04 with BLUE")
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
