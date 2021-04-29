//
//  RMStepsBar.swift
//  step
//
//  Created by Mihail Terekhov on 22.04.2021.
//

import UIKit

public protocol RMStepsBarDataSource: AnyObject {
    
    func numberOfStepsInStepsBar(stepbar: RMStepsBar) -> Int
    func stepsBar(stepbar: RMStepsBar, stepAtIndex: Int) -> RMStep
    
}

public protocol RMStepsBarDelegate: UIToolbarDelegate {
    
    func stepsBarDidSelectCancelButton(bar: RMStepsBar)
    func stepsBar(bar: RMStepsBar, shouldSelectStepAtIndex: Int)
}

public class RMStepsBar: UIToolbar {
    
    private let MinimalStepWidth: CGFloat = 40
    private let SeperatorHeight: CGFloat = 1
    private let SeperatorWidth: CGFloat = 10
    private let AnimationDuration: TimeInterval = 0.3
    private let CancelButtonWidth: CGFloat = 42
    private let CancelButtonHeight: CGFloat = 43
    private let RightSeperatorKey = "RM_RIGHT_SEPERATOR_KEY"
    private let LeftSeperatorKey = "RM_LEFT_SEPERATOR_KEY"
    private let StepWidthConstraintKey = "RM_STEP_WIDTH_CONSTRAINT_KEY"
    private let StepKey = "RM_STEP_KEY"
    
    private lazy var topLine: UIView = {
        let newView = UIView(frame: .zero)
        
        newView.backgroundColor = seperatorColor
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        return newView
    }()
    private lazy var bottomLine: UIView = {
        let newView = UIView(frame: .zero)
        
        newView.backgroundColor = seperatorColor
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        return newView
    }()
    
    private lazy var cancelButton: UIButton = {
        let newButton = UIButton(type: .custom)
        newButton.setTitle("X", for: .normal)
        newButton.setTitleColor(UIColor(white: 142.0 / 255.0, alpha: 0.5), for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        return newButton
    }()
    
    private lazy var cancelSeperator: UIView = {
        let newView = UIView(frame: .zero)
        
        newView.backgroundColor = seperatorColor
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        return newView
    }()
    
    private var cancelButtonXConstraint = NSLayoutConstraint()
    private var stepDictionaries = [[String:Any?]]()
    
    public var toolbardDelegate: RMStepsBarDelegate?
    public weak var dataSource: RMStepsBarDataSource?
    
    private var hideCancelButton = false
    public var hideNumberLabelWhenActiveStep = false
    public var allowBackward = false
    
    private var _seperatorColor = UIColor(white: 0.75, alpha: 1)
    public var seperatorColor: UIColor {
        get {
            return _seperatorColor
        }
        set {
            _seperatorColor = newValue
            topLine.backgroundColor = seperatorColor
            bottomLine.backgroundColor = _seperatorColor
            for aStepDict in stepDictionaries {
                if let stepSeperatorView = aStepDict[RightSeperatorKey] as? RMStepSeperatorView {
                    stepSeperatorView.seperatorColor = _seperatorColor
                }
            }
        }
    }
    public var indexOfSelectedStep: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        topLine.frame = CGRect(x: 0, y: frame.height - CancelButtonHeight, width: frame.width, height: 0.4)
        addSubview(topLine)
        
        bottomLine.frame = CGRect(x: 0, y: frame.height - SeperatorHeight, width: frame.width, height: SeperatorHeight)
        addSubview(bottomLine)
        
        cancelButton.frame = CGRect(x: 0, y: frame.height - CancelButtonHeight, width: CancelButtonWidth, height: 42)
        addSubview(cancelButton)
        
        cancelSeperator.frame = CGRect(x: CancelButtonWidth, y: frame.height - 44, width: SeperatorHeight, height: frame.height)
        addSubview(cancelSeperator)

        cancelButtonXConstraint = cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor)
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: topAnchor, constant: SeperatorHeight),
            topLine.heightAnchor.constraint(equalToConstant: SeperatorHeight),
            topLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: trailingAnchor),

            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: SeperatorHeight),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -SeperatorHeight),

            cancelButtonXConstraint,
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -SeperatorHeight),
            cancelButton.widthAnchor.constraint(equalToConstant: CancelButtonWidth),
            cancelButton.heightAnchor.constraint(equalToConstant: CancelButtonHeight),

            cancelSeperator.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor),
            cancelSeperator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -SeperatorHeight),
            cancelSeperator.widthAnchor.constraint(equalToConstant: SeperatorHeight),
            cancelSeperator.heightAnchor.constraint(equalToConstant: CancelButtonHeight),
        ])

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recognizedTap(recognizer:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHideCancelButton(newHideCancelButton: Bool) {
        setupHideCancelButton(newHideCancelButton: newHideCancelButton, animated: false)
    }
    
    public func setupIndexOfSelectedStep(newIndexOfSelectedStep: Int) {
        setupIndexOfSelectedStep(newIndexOfSelectedStep: newIndexOfSelectedStep, animated: false)
    }
    
    public func setupIndexOfSelectedStep(newIndexOfSelectedStep: Int, animated: Bool) {
        if newIndexOfSelectedStep == indexOfSelectedStep {
            updateSteps(animated: false)
            return
        }
        
        let oldStepDict = stepDictionaries[indexOfSelectedStep]
        let newStepDict = stepDictionaries[newIndexOfSelectedStep]
        if let constraint = newStepDict[StepWidthConstraintKey] as? NSLayoutConstraint {
            removeConstraint(constraint)
        }
        if let constraint = oldStepDict[StepWidthConstraintKey] as? NSLayoutConstraint {
            addConstraint(constraint)
        }
        indexOfSelectedStep = newIndexOfSelectedStep
        
        if animated {
            UIView.animate(withDuration: AnimationDuration,
                           delay: 0,
                           options: .beginFromCurrentState,
                           animations: { [weak self] in
                            guard let self = self else {
                                return
                            }
                            
                            self.layoutIfNeeded()
                           },
                           completion: nil)
        }
        else {
            layoutIfNeeded()
        }
        
        updateSteps(animated: animated)
    }
    
    public func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        for aStepDict in stepDictionaries {
            if let rightSeperator = aStepDict[RightSeperatorKey] as? RMStepSeperatorView {
                rightSeperator.removeFromSuperview()
            }
            guard let step = aStepDict[StepKey] as? RMStep else {
                continue
            }
            step.stepView.removeFromSuperview()
        }
        stepDictionaries.removeAll()
        
        let numberOfSteps = dataSource.numberOfStepsInStepsBar(stepbar: self)
        if numberOfSteps < 1 {
            return
        }
        var leftSeperator: RMStepSeperatorView?
        var rightSeperator: RMStepSeperatorView?
        for i in 0...numberOfSteps - 1 {
            leftSeperator = rightSeperator
            if i == numberOfSteps - 1 {
                rightSeperator = nil
            }
            else {
                rightSeperator = RMStepSeperatorView(frame: .zero)
                rightSeperator?.seperatorColor = seperatorColor
                rightSeperator?.translatesAutoresizingMaskIntoConstraints = false
                addSubview(rightSeperator!)
            }
            let step = dataSource.stepsBar(stepbar: self, stepAtIndex: i)
            step.numberLabel.text = "\(i + 1)"
            addSubview(step.stepView)
            
            let leftEnd: UIView = leftSeperator ?? cancelSeperator
            let rightEnd: UIView = rightSeperator ?? self
            let stepView = step.stepView
            
            NSLayoutConstraint.activate([
                stepView.heightAnchor.constraint(equalToConstant: 44),
                stepView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
            if rightSeperator == nil {
                NSLayoutConstraint.activate([
                    stepView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    stepView.leadingAnchor.constraint(equalTo: leftEnd.trailingAnchor),
                ])
            } else {
                NSLayoutConstraint.activate([
                    stepView.trailingAnchor.constraint(equalTo: rightEnd.leadingAnchor),
                    stepView.leadingAnchor.constraint(equalTo: leftEnd.trailingAnchor),
                    rightEnd.widthAnchor.constraint(equalToConstant: SeperatorWidth),
                    rightEnd.heightAnchor.constraint(equalToConstant: 44),
                    rightEnd.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
            }
            
            let widthConstraint = stepView.widthAnchor.constraint(equalToConstant: MinimalStepWidth)
            if i != indexOfSelectedStep {
                NSLayoutConstraint.activate([
                    widthConstraint
                ])
            }
            
            if leftSeperator != nil && rightSeperator != nil {
               stepDictionaries.append([LeftSeperatorKey:leftSeperator,
                                        StepKey:step,
                                        RightSeperatorKey:rightSeperator,
                                        StepWidthConstraintKey:widthConstraint])
            }
            if leftSeperator != nil && rightSeperator == nil {
               stepDictionaries.append([LeftSeperatorKey:leftSeperator,
                                        StepKey:step,
                                        StepWidthConstraintKey:widthConstraint])
            }
            if leftSeperator == nil && rightSeperator != nil {
               stepDictionaries.append([StepKey:step,
                                        RightSeperatorKey:rightSeperator,
                                        StepWidthConstraintKey:widthConstraint])
            }
            
            updateSteps(animated: false)
        }
    }
    
    @objc
    private func recognizedTap(recognizer: UIGestureRecognizer) {
        let touchLocation = recognizer.location(in: self)
        for (index, aStepDict) in stepDictionaries.enumerated() {
            guard let step = aStepDict[StepKey] as? RMStep else {
                continue
            }
            if !step.stepView.frame.contains(touchLocation) {
                continue
            }
            
            if index < indexOfSelectedStep && allowBackward {
                toolbardDelegate?.stepsBar(bar: self, shouldSelectStepAtIndex: index)
            }
        }
    }
    
    @objc
    private func cancelButtonTapped() {
        guard let toolbardDelegate = toolbardDelegate else {
            return
        }
        
        toolbardDelegate.stepsBarDidSelectCancelButton(bar: self)
    }
    
    private func stepAnimationsEnabledColor(step: RMStep) {
        stepAnimations(step: step,
                       barColor: step.enabledBarColor,
                       textColor: step.enabledTextColor,
                       hideNumber: false)
    }
    
    private func stepAnimationsSelectedColor(step: RMStep) {
        stepAnimations(step: step,
                       barColor: step.selectedBarColor,
                       textColor: step.selectedTextColor,
                       hideNumber: hideNumberLabelWhenActiveStep)
    }
    
    private func stepAnimationsDisabledColor(step: RMStep) {
        stepAnimations(step: step,
                       barColor: step.disabledBarColor,
                       textColor: step.disabledTextColor,
                       hideNumber: false)
    }
    
    private func stepAnimations(step: RMStep, barColor: UIColor, textColor: UIColor, hideNumber: Bool) {
        step.stepView.backgroundColor = barColor
        step.titleLabel.textColor = textColor
        step.numberLabel.textColor = textColor
        step.circleLayer.strokeColor = textColor.cgColor
        step.hideNumberLabel = hideNumber
    }

    private func updateSteps(animated: Bool) {
        for (idx, aStepDict) in stepDictionaries.enumerated() {
            guard let step = aStepDict[StepKey] as? RMStep,
                  let leftSeperator = aStepDict[LeftSeperatorKey] as? RMStepSeperatorView,
                  let rightSeperator = aStepDict[RightSeperatorKey] as? RMStepSeperatorView else {
                continue
            }
            
            if indexOfSelectedStep > idx {
                if animated {
                    UIView.animate(withDuration: AnimationDuration,
                                   delay: 0,
                                   options: .beginFromCurrentState,
                                   animations: {
                                    self.stepAnimationsEnabledColor(step: step)
                                   }, completion:nil)
                    
                }
                else {
                    stepAnimationsEnabledColor(step: step)
                }
                leftSeperator.setupRightColor(rightColor: step.enabledBarColor, animated: animated)
                rightSeperator.setupLeftColor(leftColor: step.enabledBarColor, animated: animated)
                continue
            }
            
            if indexOfSelectedStep == idx {
                if animated {
                    UIView.animate(withDuration: AnimationDuration,
                                   delay: 0,
                                   options: .beginFromCurrentState,
                                   animations: {
                                    self.stepAnimationsSelectedColor(step: step)
                                   }, completion:nil)
                    
                }
                else {
                    stepAnimationsSelectedColor(step: step)
                }
                leftSeperator.setupRightColor(rightColor: step.selectedBarColor, animated: animated)
                rightSeperator.setupLeftColor(leftColor: step.selectedBarColor, animated: animated)
                continue
            }
            
            if indexOfSelectedStep < idx {
                if animated {
                    UIView.animate(withDuration: AnimationDuration,
                                   delay: 0,
                                   options: .beginFromCurrentState,
                                   animations: {
                                    self.stepAnimationsDisabledColor(step: step)
                                   }, completion:nil)
                    
                }
                else {
                    stepAnimationsDisabledColor(step: step)
                }
                leftSeperator.setupRightColor(rightColor: step.disabledBarColor, animated: animated)
                rightSeperator.setupLeftColor(leftColor: step.disabledBarColor, animated: animated)
                continue
            }
        }
    }
    
    private func setupHideCancelButton(newHideCancelButton: Bool, animated: Bool) {
        hideCancelButton = newHideCancelButton
        if newHideCancelButton {
            cancelButtonXConstraint.constant = -CancelButtonWidth - 1
        }
        else {
            cancelButtonXConstraint.constant = 0
        }
        
        if !animated {
            return
        }
        
        UIView.animate(withDuration: AnimationDuration) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.layoutIfNeeded()
        }
    }
    
}
