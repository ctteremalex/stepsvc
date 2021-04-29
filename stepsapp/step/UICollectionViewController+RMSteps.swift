//
//  UITableViewController.swift
//  step
//
//  Created by Mihail Terekhov on 26.04.2021.
//

import UIKit

extension UICollectionViewController {
    
    public func adaptToEdgeInsets(newInsets: UIEdgeInsets) {
        collectionView.contentInset = newInsets;
        collectionView.scrollIndicatorInsets = newInsets;
    }
    
}
