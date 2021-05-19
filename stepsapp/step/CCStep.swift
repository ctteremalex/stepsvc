//
//  CCStep.swift
//  stepsapp
//
//  Created by Mihail Terekhov on 29.04.2021.
//

import UIKit

public typealias StepSelectionHandler = () -> Void

/// Content with processing step completeness
public protocol StepContentView {
    /// Step content is ready to jump out
    var stepIsReady: Bool { get }
    
    /// Step title to show as tile name
    var stepTitle: String? { get }
    
    /// Call it to show an incompleteness error
    func showIncompleteError()
}

extension StepContentView {
    /// If needed return self as UIViewController
    var asController: UIViewController? {
        self as? UIViewController
    }
}

/// Model of step for CCStepsViewController
public struct CCStep {
    public enum Position {
        case left
        case right
        case middle
    }
    
    public struct Width {
        let minimum: CGFloat
        let value: CGFloat
    }
    
    public var position: Position
    public var image: UIImage?
    public var stepLabelWidth: Width = .init(minimum: 0, value: 1)
    public var viewController: StepContentView
    
    public var canJumpToStep: ((_ index: Int) -> Bool)
}
