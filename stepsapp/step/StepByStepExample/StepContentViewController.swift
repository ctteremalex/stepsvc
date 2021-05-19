//
//  ViewController.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 28.04.2021.
//

import UIKit

class StepContentViewController: UIViewController, CCStepsDataSource {
    private enum Constants {
        static let stepCellId: String = "step"
        static let horizontalInset: CGFloat = 8
    }
    
    private var currentIndex: Int = 0
    
    func didSelected(step: Int) {
        currentIndex = step
        debugPrint("selected step is \(step)")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        stepsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.stepCellId, for: indexPath) as! CCStepScalingCell
        
        cell.backgroundColor = .gray
        cell.config(step: stepsList[indexPath.row])
        cell.didChangedSelection(isSelected: cell.isSelected)
        return cell
    }
    
    @IBOutlet private weak var nextButton: UIBarButtonItem!
    @IBOutlet private weak var previousButton: UIBarButtonItem!
    
    private var stepsController: CCStepsViewController!
    
    private var stepsList = [CCStep]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let controller = CCStepsViewController(stepsDataSource: self)
        stepsController = controller
        
        let width: CCStep.Width = .init(minimum: 100, value: 100)
        
        let vc1 = StepViewController()
        vc1.title = "VC1"
        vc1.view.backgroundColor = .green
        stepsList.append(CCStep(position: .left, stepLabelWidth: width, viewController: vc1, canJumpToStep: canJumpTo))

        let vc2 = StepViewController()
        vc2.title = "VC2"
        vc2.view.backgroundColor = .red
        stepsList.append(CCStep(position: .middle, stepLabelWidth: width, viewController: vc2, canJumpToStep: canJumpTo))

        let vc3 = StepViewController()
        vc3.title = "VC3"
        vc3.view.backgroundColor = .yellow
        stepsList.append(CCStep(position: .middle, stepLabelWidth: width, viewController: vc3, canJumpToStep: canJumpTo))

        let vc4 = StepViewController()
        vc4.title = "VC4"
        vc4.view.backgroundColor = .blue
        stepsList.append(CCStep(position: .middle, stepLabelWidth: width, viewController: vc4, canJumpToStep: canJumpTo))
        
        let vc5 = StepViewController()
        vc5.title = "VC5"
        vc5.view.backgroundColor = .brown
        stepsList.append(CCStep(position: .middle, stepLabelWidth: width, viewController: vc5, canJumpToStep: canJumpTo))
        
        let vc6 = StepViewController()
        vc6.title = "VC6"
        vc6.view.backgroundColor = .cyan
        stepsList.append(CCStep(position: .right, stepLabelWidth: width, viewController: vc6, canJumpToStep: canJumpTo))
        
        if #available(iOS 13.0, *) {
            stepsList[0].image = .actions
        } else {
            // Fallback on earlier versions
        }
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Next", style: .done, target: controller, action: #selector(controller.jumpToNext)),
            UIBarButtonItem(title: "Previous", style: .done, target: controller, action: #selector(controller.jumpToPrevious))
        ]
        
        controller.configCollection { collection in
            let stepNib = UINib(nibName: "CCStepScalingCell", bundle: nil)
            collection.register(stepNib, forCellWithReuseIdentifier: Constants.stepCellId)
            collection.contentInset = .init(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        }
        
        updateCellSize(size: view.frame.size, rotating: false)
        
        /// this line can load view of CCStepsViewController, so call updateCellSize before here
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
    
    /// Build own width's logic for cells
    private func updateCellSize(size: CGSize, rotating: Bool) {
        let count = numberOfSteps
        
        let orientation = UIDevice.current.orientation
        let insets: CGFloat
        if orientation.isLandscape {
            insets = rotating ? view.safeAreaInsets.left + view.safeAreaInsets.right : 0
        } else {
            insets = 0
        }
        
        let widthValue = (size.width - insets - Constants.horizontalInset * 2) / (CGFloat(count))
        let width = CCStep.Width(minimum: widthValue, value: widthValue)
        
        (0..<count).forEach { step in
            stepsList[step].stepLabelWidth = width
        }
        
        if rotating {
            stepsController.invalidateIntrinsicContentSize()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: {[weak self] _ in
            self?.updateCellSize(size: size, rotating: true)
        })
    }
    
    var numberOfSteps: Int {
        stepsList.count
    }
    
    func selectedStepWidthAtIndex(index: Int) -> CGFloat {
        stepsList[index].stepLabelWidth.value
    }
    
    func minimalStepWidthAtIndex(index: Int) -> CGFloat {
        let label = UILabel()
        label.text = stepsList[index].viewController.stepTitle
        label.sizeToFit()
        let size = label.frame.size.width
        let iconSize: CGFloat = stepsList[index].image == nil ? 0 : 22
        if stepsList[index].stepLabelWidth.minimum < size {
            stepsList[index].stepLabelWidth = .init(minimum: size + iconSize + 20, value: stepsList[index].stepLabelWidth.value)
            return size + iconSize + 20
        } else {
            return stepsList[index].stepLabelWidth.minimum
        }
    }
    
    func canJumpTo(step: Int) -> Bool {
        stepsList[currentIndex].viewController.stepIsReady
    }
    
    func stepAtIndex(index: Int) -> CCStep {
        stepsList[index]
    }
}
