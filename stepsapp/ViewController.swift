//
//  ViewController.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 28.04.2021.
//

import UIKit

fileprivate let MinimalStepWidth: CGFloat = 80

class ViewController: UIViewController, CCStepsDataSource {
    var currentIndex: Int = 0
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        indexPath.section == 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        stepsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "step", for: indexPath) as! CCStepCell
        
        cell.backgroundColor = .gray
        cell.config(step: stepsList[indexPath.row])
        return cell
    }
    
    @IBOutlet private weak var nextButton: UIBarButtonItem!
    @IBOutlet private weak var previousButton: UIBarButtonItem!
    
    private var stepsList = [CCStep]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let controller = CCStepsViewController(stepsDataSource: self)
        
        let count = 6
        let spacing = 0
        //controller.mini (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        let widthValue = (view.frame.width) / (CGFloat(count) + 1)
        
        let width: CCStep.Width = .init(minimum: widthValue, value: widthValue * 2)
        
        let vc1 = StepViewController()
        vc1.title = "VC1"
        vc1.view.backgroundColor = .green
        stepsList.append(CCStep(position: .left, stepLabelWidth: width, viewController: vc1, selectionBlock: {
            print("selected step is 01 with GREEN")
        }, canJumpToStep: canJumpTo))

        let vc2 = StepViewController()
        vc2.title = "VC2"
        vc2.view.backgroundColor = .red
        stepsList.append(CCStep(position: .middle, stepLabelWidth: width, viewController: vc2, selectionBlock: {
            print("selected step is 02 with RED")
        }, canJumpToStep: canJumpTo))

        let vc3 = StepViewController()
        vc3.title = "VC3"
        vc3.view.backgroundColor = .yellow
        stepsList.append(CCStep(position: .middle, stepLabelWidth: width, viewController: vc3, selectionBlock: {
            print("selected step is 03 with YELLOW")
        }, canJumpToStep: canJumpTo))

        let vc4 = StepViewController()
        vc4.title = "VC4"
        vc4.view.backgroundColor = .blue
        stepsList.append(CCStep(position: .middle, stepLabelWidth: width, viewController: vc4, selectionBlock: {
            print("selected step is 04 with BLUE")
        }, canJumpToStep: canJumpTo))
        
        let vc5 = StepViewController()
        vc5.title = "VC5"
        vc5.view.backgroundColor = .brown
        stepsList.append(CCStep(position: .middle, stepLabelWidth: width, viewController: vc5, selectionBlock: {
            print("selected step is 05 with BROWN")
        }, canJumpToStep: canJumpTo))
        
        let vc6 = StepViewController()
        vc6.title = "VC6"
        vc6.view.backgroundColor = .cyan
        stepsList.append(CCStep(position: .right, stepLabelWidth: width, viewController: vc6, selectionBlock: {
            print("selected step is 06 with CYAN")
        }, canJumpToStep: canJumpTo))
        
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Next", style: .done, target: controller, action: #selector(controller.jumpToNext)),
            UIBarButtonItem(title: "Previous", style: .done, target: controller, action: #selector(controller.jumpToPrevious))
        ]
        
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
    
    func selectedStepWidthAtIndex(index: Int) -> CGFloat {
        stepsList[index].stepLabelWidth.value
    }
    
    func minimalStepWidthAtIndex(index: Int) -> CGFloat {
        stepsList[index].stepLabelWidth.minimum
    }
    
    func canJumpTo(step: Int) -> Bool {
        stepsList[currentIndex].viewController.stepIsReady
    }
    
    func stepAtIndex(index: Int) -> CCStep {
        stepsList[index]
    }
}
