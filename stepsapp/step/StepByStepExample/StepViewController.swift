//
//  StepViewController.swift
//  stepsapp
//
//  Created by Ali on 04.05.2021.
//

import UIKit
import SnapKit

final class StepViewController: UIViewController {
    var stepTitle: String? {
        title
    }
    
    var stepIsReady: Bool = false
    
    /// custom logic-UI to handle form in view ccontroller
    lazy var checkSwitch: UISwitch = {
        let switcher = UISwitch(frame: .init(origin: .zero, size: .init(width: 100, height: 100)))
        
        
        view.addSubview(switcher)
        
        switcher.snp.makeConstraints { maker in
            maker.center.equalTo(view)
        }
        
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
