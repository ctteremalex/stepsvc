//
//  ViewController.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 28.04.2021.
//

import UIKit

class ViewController: RMStepsController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func createViewController(color: UIColor) -> RMStepsController {
        let newViewController = RMStepsController()
        newViewController.view.backgroundColor = color
        return newViewController
    }

    override func stepViewControllers() -> [RMStepsController] {
        let firstStep = createViewController(color: .red)
        firstStep.step.title = "First"

        let secondStep = createViewController(color: .green)
        secondStep.step.title = "Second"

        let thirdStep = createViewController(color: .yellow)
        thirdStep.step.title = "Third"

        let fourthStep = createViewController(color: .blue)
        fourthStep.step.title = "Fourth"

        return [firstStep, secondStep, thirdStep, fourthStep]
    }

    override func finishedAllSteps() {
        dismiss(animated: true)
    }

    override func canceled() {
        dismiss(animated: true)
    }}

