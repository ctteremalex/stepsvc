//
//  CCStepCell.swift
//  stepsapp
//
//  Created by Ali on 06.05.2021.
//

import UIKit

class CCStepCell: UICollectionViewCell {
    enum Constants {
        static let selectedColor: UIColor = .blue
        static let incompletedColor: UIColor = .orange
        static let completedColor: UIColor = .green
    }
    
    private var step: CCStep?
    
    private lazy var arrowLayer: CAShapeLayer = {
        let arrow = CAShapeLayer()
        arrow.strokeColor = UIColor.white.cgColor
        arrow.lineWidth = 4
        layer.insertSublayer(arrow, at: 0)
        return arrow
    }()
    
    @IBOutlet private var propertyLabel: UILabel!
    @IBOutlet private var background: UIView!
    
    /// config the cell with CCStep
    func config(step: CCStep) {
        self.step = step
        
        background.backgroundColor = .clear
        selectedBackgroundView = background
        backgroundColor = .clear
        
        propertyLabel.text = step.viewController.title
        propertyLabel.textColor = .white
        propertyLabel.textAlignment = .center
        
        if isSelected {
            addArrow(posititon: step.position)
        } else {
            unselectedArrow(posititon: step.position, isReady: step.viewController.stepIsReady)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            let isReady = step?.viewController.stepIsReady ?? false
            if isSelected {
                addArrow(posititon: step?.position ?? .middle)
            } else {
                unselectedArrow(posititon: step!.position, isReady: isReady)
            }
        }
    }
    
    private var width: CGFloat {
        (isSelected ? step?.stepLabelWidth.value : step?.stepLabelWidth.minimum) ?? bounds.width
    }
    
    private func addArrow(posititon: CCStep.Position) {
        let arrow = UIBezierPath.stepPath(position: posititon, width: width, height: bounds.height, midY: bounds.midY)
        
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = Constants.selectedColor.cgColor
    }
    
    private func unselectedArrow(posititon: CCStep.Position, isReady: Bool) {
        let arrow = UIBezierPath.stepPath(position: posititon, width: width, height: bounds.height, midY: bounds.midY)
        
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = (isReady ? Constants.completedColor : Constants.incompletedColor).cgColor
    }
}

private extension UIBezierPath {
    static func stepPath(position: CCStep.Position, width: CGFloat, height: CGFloat, midY: CGFloat) -> UIBezierPath {
        switch position {
        case .left:
            return .leftSideArrow(from: CGPoint(x: 0, y: midY), to: CGPoint(x: width, y: midY), tailWidth: 10, headWidth: height - 8)
        case .right:
            return .rightSideArrow(from: CGPoint(x: 0, y: midY), to: CGPoint(x: width, y: midY), tailWidth: 10, headWidth: height - 8)
        default:
            return .arrowLTR(from: CGPoint(x: 0, y: midY), to: CGPoint(x: width, y: midY), tailWidth: 10, headWidth: height - 8)
        }
    }
    
    static func rightSideArrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
        
        let radius = headWidth / 2
        let points: [CGPoint] = [
            p(0, -headWidth / 2), // left upper angle
            p(tailWidth, 0), // left inner tail
            p(0, headWidth / 2), // left bottom angle
        ]
        
        let subPath = CGMutablePath()
        subPath.move(to: points[0])
        subPath.addLine(to: points[1])
        subPath.addLine(to: points[2])
        subPath.addArc(center: p(length - radius, 1), radius: radius, startAngle: .pi / 2, endAngle: 3 * .pi/2, clockwise: true)
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
        
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
        
        let radius = headWidth / 2
        let points: [CGPoint] = [
            p(length, -headWidth / 2),
            p(length + tailWidth, 0),
            p(length, headWidth / 2),
        ]
        
        let subPath = CGMutablePath()
        subPath.move(to: points[0])
        subPath.addLine(to: points[1])
        subPath.addLine(to: points[2])
        subPath.addArc(center: p(radius, 1), radius: radius, startAngle: .pi / 2, endAngle: 3 * .pi/2, clockwise: false)
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

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
        let points: [CGPoint] = [
            p(0, -headWidth / 2), // left upper angle
            p(tailWidth, 0), // left inner tail
            p(0, headWidth / 2), // left bottom angle
            p(length, headWidth / 2),
            p(length + tailWidth, 0),
            p(length, -headWidth / 2),
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
