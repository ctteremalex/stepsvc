//
//  RMStep.swift
//  step
//
//  Created by Mihail Terekhov on 22.04.2021.
//

import UIKit

public class RMStep {
    private var _stepView: UIView?
    public var stepView: UIView {
        get {
            if _stepView == nil {
                let newStepView = UIView(frame: .zero)
                newStepView.translatesAutoresizingMaskIntoConstraints = false
                newStepView.layer.addSublayer(circleLayer)
                newStepView.addSubview(numberLabel)
                newStepView.addSubview(titleLabel)
                _stepView = newStepView
                updateConstrains()
            }
            
            return _stepView!
        }
        set {
            
        }
    }
    
    public lazy var numberLabel: UILabel = {
        let newLabel = createLabel()
        newLabel.text = "0";
        newLabel.textAlignment = .center;
        return newLabel
    }()
    
    public lazy var titleLabel: UILabel = {
        let newLabel = createLabel()
        newLabel.text = title;
        newLabel.textAlignment = .left;
        return newLabel
    }()
    
    public lazy var circleLayer: CAShapeLayer = {
        let newLayer = CAShapeLayer()
        
        let radius: CGFloat = 12
        newLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath
        newLayer.position = CGPoint(x: 9, y: 10)
        newLayer.fillColor = UIColor.clear.cgColor
        newLayer.strokeColor = disabledTextColor.cgColor
        newLayer.lineWidth = 1
        
        return newLayer
    }()

    /**
     Provides access to the title of this step as it is used by an instance of `RMStepsBar`.
     */
    public var title: String {
        get {
            return titleLabel.text ?? ""
        }
        set {
            titleLabel.text = newValue
        }
    }

    /**
     Provides access to the selected bar color of this step as it is used by an instance of `RMStepsBar`.
     */
    public lazy var selectedBarColor: UIColor = UIColor(red: 23.0 / 255.0, green: 220.0 / 255.0, blue: 108.0 / 255.0, alpha: 1)

    /**
     Provides access to the enabled bar color of this step as it is used by an instance of `RMStepsBar`.
     */
    public lazy var enabledBarColor: UIColor = UIColor(white: 142.0 / 255.0, alpha: 0.5)

    /**
     Provides access to the disabled bar color of this step as it is used by an instance of `RMStepsBar`.
     */
    public lazy var disabledBarColor: UIColor = .clear
    
    /**
     Provides access to the selected text color of this step as it is used by an instance of `RMStepsBar`.
     */
    public lazy var selectedTextColor: UIColor = UIColor(white: 1, alpha: 1)

    /**
     Provides access to the enabled text color of this step as it is used by an instance of `RMStepsBar`.
     */
    public lazy var enabledTextColor: UIColor = UIColor(white: 1, alpha: 1)

    /**
     Provides access to the disabled text color of this step as it is used by an instance of `RMStepsBar`.
     */
    public lazy var disabledTextColor: UIColor = UIColor(white: 0.75, alpha: 1)

    /**
     Provides access to the hide or show number label of this step.
     */
    private var _hideNumberLabel = false
    public var hideNumberLabel: Bool {
        get {
            return _hideNumberLabel
        }
        set {
            _hideNumberLabel = newValue
            for constraint in stepView.constraints {
                stepView.removeConstraint(constraint)
            }
            numberLabel.isHidden = _hideNumberLabel
            circleLayer.isHidden = _hideNumberLabel
            updateConstrains()
        }
    }

    private func updateConstrains() {
        var leftMarginConstraints = [NSLayoutConstraint]()
        
        if hideNumberLabel {
            leftMarginConstraints.append(titleLabel.leadingAnchor.constraint(equalTo: stepView.leadingAnchor, constant: 8))
            leftMarginConstraints.append(titleLabel.trailingAnchor.constraint(equalTo: stepView.trailingAnchor))
        } else {
            leftMarginConstraints.append(titleLabel.leadingAnchor.constraint(equalTo: stepView.leadingAnchor, constant: 40))
            leftMarginConstraints.append(titleLabel.trailingAnchor.constraint(equalTo: stepView.trailingAnchor))
            NSLayoutConstraint.activate([
                numberLabel.leadingAnchor.constraint(equalTo: stepView.leadingAnchor, constant: 11),
                numberLabel.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 9),
                numberLabel.topAnchor.constraint(equalTo: stepView.topAnchor),
                numberLabel.bottomAnchor.constraint(equalTo: stepView.bottomAnchor),
            ])
        }
        leftMarginConstraints.append(titleLabel.topAnchor.constraint(equalTo: stepView.topAnchor))
        leftMarginConstraints.append(titleLabel.bottomAnchor.constraint(equalTo: stepView.bottomAnchor))
        NSLayoutConstraint.activate(leftMarginConstraints)
        
        stepView.setNeedsUpdateConstraints()
    }

    private func createLabel() -> UILabel {
        let newLabel = UILabel(frame: .zero)
        
        newLabel.textColor = disabledTextColor;
        newLabel.backgroundColor = .clear
        newLabel.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        newLabel.translatesAutoresizingMaskIntoConstraints = false;

        return newLabel
    }
    
}
