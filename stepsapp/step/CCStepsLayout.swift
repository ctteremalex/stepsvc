//
//  CCStepsLayout.swift
//  stepsapp
//
//  Created by Ali on 06.05.2021.
//

import UIKit

enum Section: Int, CaseIterable {
        case steps
        case content

    func columnCount(for width: CGFloat) -> Int {
        switch self {
        case .steps:
            return 3
        case .content:
            return 1
        }
    }
    
    var relationHeight: CGFloat {
        switch self {
        case .steps:
            return 0.1
        case .content:
            return 1
        }
    }
}

enum CCStepsLayout {
    static func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let columns = sectionKind.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)

            let innerInset: CGFloat = 2
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(100),
                heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 0, leading: innerInset, bottom: 0, trailing: innerInset)

            let groupHeight: NSCollectionLayoutDimension
            let groupWidth: NSCollectionLayoutDimension
            let group: NSCollectionLayoutGroup
            switch sectionKind {
            case .content:
                groupHeight = .absolute(layoutEnvironment.container.effectiveContentSize.height - 44 - 2 * innerInset)
                groupWidth = .fractionalWidth(1)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: groupWidth,
                    heightDimension: groupHeight)
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            case .steps:
                groupHeight = .absolute(44)
                if columns > 3 {
                    groupWidth = .estimated(200)
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: groupWidth,
                        heightDimension: groupHeight)
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                } else {
                    groupWidth = .fractionalWidth(1)
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: groupWidth,
                        heightDimension: groupHeight)
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
                }
            }

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: innerInset, leading: 0, bottom: 0, trailing: 0)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
        return layout
    }
}
