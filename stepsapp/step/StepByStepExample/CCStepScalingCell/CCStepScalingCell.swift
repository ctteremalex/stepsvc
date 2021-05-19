//
//  CCStepFadingCell.swift
//  stepsapp
//
//  Created by Ali on 06.05.2021.
//

import UIKit

class CCStepScalingCell: UICollectionViewCell, SelectableStepCell, CAAnimationDelegate {
    enum Constants {
        static let selectedColor: UIColor = .blue
        static let incompletedColor: UIColor = .orange
        static let completedColor: UIColor = .green
        static let deltaWidth: CGFloat = 16
    }
    
    private var step: CCStep?
    
    private lazy var arrowLayer: CAShapeLayer = {
        let arrow = CAShapeLayer()
        arrow.strokeColor = UIColor.white.cgColor
        arrow.lineWidth = 4
        arrow.backgroundColor = UIColor.black.cgColor
        arrow.position = .init(x: arrow.position.x, y: center.y)
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
        
        let beginScale: CGFloat
        let endScale: CGFloat
        
        let ratio: CGFloat = (cellWidth + Constants.deltaWidth) / cellWidth
        
        if isSelected {
            beginScale = 1
            endScale = ratio
           arrowLayer.fillColor = Constants.selectedColor.cgColor
        } else {
            beginScale = ratio
            endScale = 1
            arrowLayer.fillColor = (isReady ? Constants.completedColor : Constants.incompletedColor).cgColor
        }
        
        arrowLayer.removeAllAnimations()
        
        let transAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        transAnimation.fromValue = isSelected ? 0 : -Constants.deltaWidth / 2
        transAnimation.toValue = isSelected ? -Constants.deltaWidth / 2 : 0
        transAnimation.isCumulative = true
        transAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = beginScale
        scaleAnimation.toValue = endScale
        scaleAnimation.isCumulative = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let group: CAAnimationGroup = CAAnimationGroup()
        group.animations = [transAnimation, scaleAnimation]
        group.delegate = self
        group.isRemovedOnCompletion = false
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let transform: CGAffineTransform = .init(translationX: isSelected ? -Constants.deltaWidth / 2 : 0, y: 0)
        arrowLayer.setAffineTransform(transform.scaledBy(x: endScale, y: endScale))
        arrowLayer.add(group, forKey: "transScale")
        
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
        let arrow = UIBezierPath.stepPath(position: posititon, width: cellWidth, height: bounds.height, midY: bounds.midY)
        
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = Constants.selectedColor.cgColor
    }
    
    private func unselectedArrow(posititon: CCStep.Position, isReady: Bool) {
        let arrow = UIBezierPath.stepPath(position: posititon, width: cellWidth, height: bounds.height, midY: bounds.midY)
        
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = (isReady ? Constants.completedColor : Constants.incompletedColor).cgColor
    }
}

private extension UIBezierPath {
    static func stepPath(position: CCStep.Position, width: CGFloat, height: CGFloat, midY: CGFloat) -> UIBezierPath {
        switch position {
        case .left:
            return .leftSideArrow(from: .zero, to: CGPoint(x: width, y: 0), tailWidth: 10, headWidth: height - 8)
        case .right:
            return .rightSideArrow(from: .zero, to: CGPoint(x: width, y: 0), tailWidth: 10, headWidth: height - 8)
        default:
            return .arrowLTR(from: .zero, to: CGPoint(x: width, y: 0), tailWidth: 10, headWidth: height - 8)
        }
    }
    
    static func rightSideArrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        
        let radius = headWidth / 2
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 0), // left upper angle
            CGPoint(x: tailWidth, y: headWidth / 2), // left inner tail
            CGPoint(x: 0, y: headWidth), // left bottom angle
        ]
        
        let subPath = CGMutablePath()
        subPath.move(to: points[0])
        subPath.addLine(to: points[1])
        subPath.addLine(to: points[2])
        subPath.addArc(center: CGPoint(x: length - radius, y: headWidth / 2), radius: radius, startAngle: .pi / 2, endAngle: 3 * .pi/2, clockwise: true)
        subPath.closeSubpath()
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: -headWidth / 2)

        let path = CGMutablePath()
        path.addPath(subPath, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }
    
    static func leftSideArrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        
        let radius = headWidth / 2
        let points: [CGPoint] = [
            CGPoint(x: length, y: 0),
            CGPoint(x: length + tailWidth, y: headWidth / 2),
            CGPoint(x: length, y: headWidth)
        ]
        
        let subPath = CGMutablePath()
        subPath.move(to: points[0])
        subPath.addLine(to: points[1])
        subPath.addLine(to: points[2])
        subPath.addArc(center: CGPoint(x: radius, y: headWidth / 2), radius: radius, startAngle: .pi / 2, endAngle: 3 * .pi/2, clockwise: false)
        subPath.closeSubpath()
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: -headWidth / 2)

        let path = CGMutablePath()
        path.addPath(subPath, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }
    
    static func arrowLTR(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)

        let points: [CGPoint] = [
            CGPoint(x: 0, y: 0), // left upper angle
            CGPoint(x: tailWidth, y: headWidth / 2), // left inner tail
            CGPoint(x: 0, y: headWidth), // left bottom angle
            CGPoint(x: length, y: headWidth),
            CGPoint(x: length + tailWidth, y: headWidth / 2),
            CGPoint(x: length, y: 0)
        ]

        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: -headWidth / 2)

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }
}
