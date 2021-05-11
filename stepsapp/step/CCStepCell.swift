//
//  CCStepCell.swift
//  stepsapp
//
//  Created by Ali on 06.05.2021.
//

import UIKit

class CCStepCell: UICollectionViewCell {
    @IBOutlet private var propertyLabel: UILabel!
    
    
    func config(step: CCStep) {
        let view = UIButton(frame: bounds)
        view.backgroundColor = .red
        selectedBackgroundView = view
        
        propertyLabel.text = step.viewController.title
    }
}
