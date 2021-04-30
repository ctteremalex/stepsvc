//
//  CCStepBarContainerView.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 30.04.2021.
//

import UIKit

public typealias StepsContainerTapHandler = () -> Void

class CCStepsBarContainerView: UIView {

    public var tapBlock: StepsContainerTapHandler?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func containerTapped() {
        guard let tapBlock = tapBlock else {
            return
        }
        
        tapBlock()
    }
    
}
