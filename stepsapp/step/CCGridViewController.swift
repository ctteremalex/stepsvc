//
//  CCGridViewController.swift
//  stepsapp
//
//  Created by Herman on 5/8/21.
//

import UIKit
import SnapKit

public class CCGridViewController: UIViewController, CCGridViewControllerDataSource, CCGridViewControllerDelegate {
    
    /// Надо будет задавать это в каком-нибудь датасорсе
    
    public var numberOfRows = 20
    public var numberOfColumns = 6
    
    public var sections: [CCSection] = []
    
    /// -----
    
    var sectionViews: [CCGridSectionView] = []
    
    private var screenWidth: CGFloat { super.view.bounds.width }
    private var gridWidth: CGFloat { screenWidth / CGFloat(numberOfColumns) }
    
    /// Ширина экрана меньше которой будет активироваться вид "один под другим"
    private let widthForOneUnderTheOtherLayout: CGFloat = 1000
    
    lazy var containerView: UIView = {
        containerView = UIView()
        return containerView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.addSubview(containerView)
        return scrollView
    }()
    
    public override func viewDidLoad() {
        view.addSubview(scrollView)
        createConstraints()
        generateRandomSections()
//        createSections()
        checkSizeOrPositionErrors()
        checkOverlapping()
        if view.frame.size.width > widthForOneUnderTheOtherLayout {
            arrangeSectionsDefault()
        } else {
            arrangeSectionsOneUnderTheOther()
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > widthForOneUnderTheOtherLayout {
            arrangeSectionsDefault()
        } else {
            arrangeSectionsOneUnderTheOther()
        }
    }
    
    private func createConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func generateRandomSections() {
        sections = [
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get(),
            RandomSection.get()
        ]
    }
    
    private func createSections() {
        sections = [
            CCSection(id: 1, color: .blue, label: "Test", type: .currentRecord, rect: CGRect(x: 1, y: 1, width: 1, height: 2)),
            CCSection(id: 2, color: .red, label: "Test2", type: .currentRecord, rect: CGRect(x: 1, y: 2, width: 1, height: 2)),
            CCSection(id: 3, color: .magenta, label: "Test3", type: .currentRecord, rect: CGRect(x: 0, y: 8, width: 6, height: 4))
        ]
    }
    
    private func checkSizeOrPositionErrors() {
        sections.removeAll { $0.width <= 0 || $0.height <= 0 || $0.xPos + $0.width > CGFloat(numberOfColumns) || $0.yPos + $0.height > CGFloat(numberOfRows) }
    }
    
    private func checkOverlapping() {
        
        // TODO: иногда все равно пересекаются
        
        var nonOverlappingSections: [CCSection] = []
        nonOverlappingSections.reserveCapacity(sections.count)
        
        for (index, first) in sections.enumerated() {
            var isValid = true
            if index + 1 < sections.count - 1 {
                for second in index + 1...sections.count - 1 {
                    let second = sections[second]
                    if first.rect.intersects(second.rect) {
                        isValid = false
                        break
                    }
                }
            }
            if isValid {
                nonOverlappingSections.append(first)
            }
        }
        sections = nonOverlappingSections
    }
    
    private func arrangeSectionsDefault() {
        clearSectionViews()
        var indexOfBottomSection = 0
        var yPosOfBottomSection: CGFloat = 0
        for (index, section) in sections.enumerated() {
            let sectionView = CCGridSectionView(style: .standart, title: section.label, headerColor: section.color, contentColor: .white)
            containerView.addSubview(sectionView)
            sectionViews.append(sectionView)
            
            if section.yPos + section.height > yPosOfBottomSection {
                yPosOfBottomSection = section.yPos + section.height
                indexOfBottomSection = index
            }
            sectionView.snp.remakeConstraints { make in
                make.width.equalTo(gridWidth * section.width)
                make.height.equalTo(gridWidth * section.height)
                make.leading.equalToSuperview().offset(gridWidth * section.xPos)
                make.top.equalToSuperview().offset(gridWidth * section.yPos)
            }
        }
        guard sectionViews.indices.contains(indexOfBottomSection) else { return }
        sectionViews[indexOfBottomSection].snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
    
    private func arrangeSectionsOneUnderTheOther() {
        clearSectionViews()
        var lastSectionLowestYPos: CGFloat = 0
        for section in sections {
            let sectionView = CCGridSectionView(style: .standart, title: section.label, headerColor: section.color, contentColor: .white)
            containerView.addSubview(sectionView)
            sectionViews.append(sectionView)
            
            sectionView.snp.remakeConstraints { make in
                make.width.equalTo(gridWidth * section.width)
                make.height.equalTo(gridWidth * section.height)
                // TODO: может по центру их
                make.leading.equalToSuperview()
                make.top.equalToSuperview().offset(lastSectionLowestYPos)
            }
            lastSectionLowestYPos += section.height * gridWidth
        }
        sectionViews.last?.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
    
    private func clearSectionViews() {
        sectionViews = []
        containerView.subviews.forEach { $0.removeFromSuperview() }
    }
}


public protocol CCGridViewControllerDataSource {
    var sections: [CCSection] { get set }
    var numberOfRows: Int { get set }
    var numberOfColumns: Int { get set }
}

public protocol CCGridViewControllerDelegate {
    /// надо подумать какие могут быть методы делегата и датасорса
}
