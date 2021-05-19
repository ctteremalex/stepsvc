//
//  CCStepCell.swift
//  stepsapp
//
//  Created by Ali on 06.05.2021.
//

import UIKit

class CCStepCell: UICollectionViewCell, SelectableStepCell {
    enum Constants {
        static let selectedColor: UIColor = .blue
        static let incompletedColor: UIColor = .orange
        static let completedColor: UIColor = .green
        static let animationTimeOffset: TimeInterval = 0.1
        static let lineWidth: CGFloat = 4
        static let heightInset: CGFloat = 4
        static let tailWidth: CGFloat = 10
    }
    
    private var step: CCStep?
    
    private lazy var arrowLayer: CAShapeLayer = {
        let arrow = CAShapeLayer()
        arrow.strokeColor = UIColor.white.cgColor
        arrow.lineWidth = Constants.lineWidth
        arrow.backgroundColor = UIColor.black.cgColor
        layer.insertSublayer(arrow, at: 0)
        return arrow
    }()
    
    @IBOutlet private var titleButton: UIButton!
    @IBOutlet private var background: UIView!
    
    /// config the cell with CCStep
    func config(step: CCStep) {
        self.step = step
        
        background.backgroundColor = .clear
        selectedBackgroundView = background
        backgroundColor = .clear
        
        titleButton.setTitle(step.viewController.stepTitle, for: .normal)
        titleButton.tintColor = .black
        titleButton.imageView?.backgroundColor = .clear
        titleButton.setTitleColor(.white, for: .normal)
        titleButton.contentHorizontalAlignment = .center
        
        if isSelected {
            addArrow(posititon: step.position)
        } else {
            unselectedArrow(posititon: step.position, isReady: step.viewController.stepIsReady)
        }
        
        handleIcon()
    }
    
    func didChangedSelection(isSelected: Bool) {
        handleSelection(isSelected: isSelected)
    }
    
    override var isSelected: Bool {
        didSet {
            handleSelection(isSelected: isSelected)
        }
    }
    
    private func handleSelection(isSelected: Bool) {
        guard let step = step else {
            return
        }
        
        let isReady = step.viewController.stepIsReady
        
        let endPath: UIBezierPath
        let height = bounds.height - 2 * Constants.heightInset
        
        if isSelected {
            endPath = UIBezierPath.stepPath(position: step.position, width: step.stepLabelWidth.value, tailWidth: Constants.tailWidth, height: height, midY: bounds.midY)
           arrowLayer.fillColor = Constants.selectedColor.cgColor
        } else {
            endPath = UIBezierPath.stepPath(position: step.position, width: step.stepLabelWidth.minimum, tailWidth: Constants.tailWidth, height: height, midY: bounds.midY)
            arrowLayer.fillColor = (isReady ? Constants.completedColor : Constants.incompletedColor).cgColor
        }
        
        arrowLayer.removeAllAnimations()
        CATransaction.begin()
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.toValue = endPath.cgPath
        pathAnimation.beginTime = CACurrentMediaTime() + Constants.animationTimeOffset
        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pathAnimation.autoreverses = false
        pathAnimation.isRemovedOnCompletion = false
        CATransaction.setCompletionBlock {
            self.arrowLayer.path = endPath.cgPath
        }
        arrowLayer.add(pathAnimation, forKey: "pathAnimation")
        CATransaction.commit()
        handleIcon()
    }
    
    private func handleIcon() {
        if step?.viewController.stepIsReady == true {
            if #available(iOS 13.0, *) {
                titleButton.setImage(.strokedCheckmark, for: .normal)
            } else {
                // Fallback on earlier versions
            }
        } else {
            titleButton.setImage(step?.image, for: .normal)
        }
    }
    
    private var cellWidth: CGFloat {
        (isSelected ? step?.stepLabelWidth.value : step?.stepLabelWidth.minimum) ?? bounds.width
    }
    
    private func addArrow(posititon: CCStep.Position) {
        let height = bounds.height - 2 * Constants.heightInset
        let arrow = UIBezierPath.stepPath(position: posititon, width: cellWidth, tailWidth: Constants.tailWidth, height: height, midY: bounds.midY)
        
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = Constants.selectedColor.cgColor
    }
    
    private func unselectedArrow(posititon: CCStep.Position, isReady: Bool) {
        let height = bounds.height - 2 * Constants.heightInset
        let arrow = UIBezierPath.stepPath(position: posititon, width: cellWidth, tailWidth: Constants.tailWidth, height: height, midY: bounds.midY)
        
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = (isReady ? Constants.completedColor : Constants.incompletedColor).cgColor
    }
}

private extension UIBezierPath {
    static func stepPath(position: CCStep.Position, width: CGFloat, tailWidth: CGFloat, height: CGFloat, midY: CGFloat) -> UIBezierPath {
        switch position {
        case .left:
            return .leftSideArrow(from: CGPoint(x: 0, y: midY), to: CGPoint(x: width, y: midY), tailWidth: tailWidth, headWidth: height)
        case .right:
            return .rightSideArrow(from: CGPoint(x: 0, y: midY), to: CGPoint(x: width, y: midY), tailWidth: tailWidth, headWidth: height)
        default:
            return .arrowLTR(from: CGPoint(x: 0, y: midY), to: CGPoint(x: width, y: midY), tailWidth: tailWidth, headWidth: height)
        }
    }
    
    static func rightSideArrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        
        let radius = headWidth / 2
        let points: [CGPoint] = [
            CGPoint(x: 0, y: -headWidth / 2), // left upper angle
            CGPoint(x: tailWidth, y: 0), // left inner tail
            CGPoint(x: 0, y: headWidth / 2) // left bottom angle
        ]
        
        let subPath = CGMutablePath()
        subPath.move(to: points[0])
        subPath.addLine(to: points[1])
        subPath.addLine(to: points[2])
        subPath.addArc(center: CGPoint(x: length - radius, y: 1), radius: radius, startAngle: .pi / 2, endAngle: 3 * .pi/2, clockwise: true)
        subPath.closeSubpath()
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)

        let path = CGMutablePath()
        path.addPath(subPath, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }
    
    static func leftSideArrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        
        let radius = headWidth / 2
        let points: [CGPoint] = [
            CGPoint(x: length, y: -headWidth / 2),
            CGPoint(x: length + tailWidth, y: 0),
            CGPoint(x: length, y: headWidth / 2)
        ]
        
        let subPath = CGMutablePath()
        subPath.move(to: points[0])
        subPath.addLine(to: points[1])
        subPath.addLine(to: points[2])
        subPath.addArc(center: CGPoint(x: radius, y: 1), radius: radius, startAngle: .pi / 2, endAngle: 3 * .pi/2, clockwise: false)
        subPath.closeSubpath()
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)

        let path = CGMutablePath()
        path.addPath(subPath, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }
    
    static func arrowLTR(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)

        let points: [CGPoint] = [
            CGPoint(x: 0, y: -headWidth / 2), // left upper angle
            CGPoint(x: tailWidth, y: 0), // left inner tail
            CGPoint(x: 0, y: headWidth / 2), // left bottom angle
            CGPoint(x: length, y: headWidth / 2),
            CGPoint(x: length + tailWidth, y: 0),
            CGPoint(x: length, y: -headWidth / 2)
        ]

        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }
}
