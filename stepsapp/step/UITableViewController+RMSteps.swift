//
//  UITableViewController.swift
//  step
//
//  Created by Mihail Terekhov on 26.04.2021.
//

import UIKit

extension UITableViewController {
    
    public func adaptToEdgeInsets(newInsets: UIEdgeInsets) {
        tableView.contentInset = newInsets;
        tableView.scrollIndicatorInsets = newInsets;
    }
    
}
