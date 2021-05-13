//
//  CCStepCell.swift
//  stepsapp
//
//  Created by Ali on 06.05.2021.
//

import UIKit

class CCStepCell: UICollectionViewCell {
    @IBOutlet private var propertyLabel: UILabel!
    @IBOutlet private var background: UIView!
    
    private var arrowLayer: CAShapeLayer = .init()
    private var step: CCStep?
    
    func config(step: CCStep) {
        self.step = step
        background.backgroundColor = .clear
        selectedBackgroundView = background
        
        propertyLabel.text = step.viewController.title
        propertyLabel.textColor = .white
        switch step.position {
        case .left:
            propertyLabel.textAlignment = .left
        case .middle:
            propertyLabel.textAlignment = .center
        case .right:
            propertyLabel.textAlignment = .right
        }
        
        if step.viewController.stepIsReady {
            backgroundColor = .clear
        } else {
            backgroundColor = .clear
        }
        
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
        
        arrowLayer.strokeColor = UIColor.white.cgColor
        arrowLayer.lineWidth = 4
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = UIColor.blue.cgColor
        arrowLayer.lineJoin = CAShapeLayerLineJoin.round
        arrowLayer.lineCap = CAShapeLayerLineCap.round
        if !(layer.sublayers ?? []).contains(arrowLayer) {
            layer.addSublayer(arrowLayer)
        }
    }
    
    private func unselectedArrow(posititon: CCStep.Position, isReady: Bool) {
        let arrow = UIBezierPath.stepPath(position: posititon, width: width, height: bounds.height, midY: bounds.midY)
        
        arrowLayer.strokeColor = UIColor.white.cgColor
        arrowLayer.lineWidth = 4
        arrowLayer.path = arrow.cgPath
        
        arrowLayer.fillColor = (isReady ? UIColor.green : UIColor.orange).cgColor
        arrowLayer.lineJoin = CAShapeLayerLineJoin.round
        arrowLayer.lineCap = CAShapeLayerLineCap.round
        if !(layer.sublayers ?? []).contains(arrowLayer) {
            layer.addSublayer(arrowLayer)
        }
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
