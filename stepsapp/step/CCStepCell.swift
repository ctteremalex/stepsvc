//
//  CCStepCell.swift
//  stepsapp
//
//  Created by Ali on 06.05.2021.
//

import UIKit

class CCStepCell: UICollectionViewCell {
    @IBOutlet private var propertyLabel: UILabel!
    
    private var step: CCStep?
    
    func config(step: CCStep) {
        self.step = step
        let view = UIButton(frame: bounds)
//        view.backgroundColor = .blue
        selectedBackgroundView = view
        
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
            backgroundColor = .green
        } else {
            backgroundColor = .orange
        }
    }
    
    override var isSelected: Bool {
        didSet {
            let isReady = step?.viewController.stepIsReady ?? false
            if isSelected {
//                backgroundColor = .blue
//                layer.mask = visibilityMaskForCell(location: 0.5)
//                layer.masksToBounds = true
                
                addArrow()
            } else {
                backgroundColor = isReady ? .green : .orange
            }
        }
    }
    
    private func addArrow() {
        let arrow = UIBezierPath.arrowLTR(from: CGPoint(x: 0, y: bounds.midY), to: CGPoint(x: bounds.width, y: bounds.midY), tailWidth: 10, headWidth: bounds.height, headLength: bounds.height)

        let arrowLayer = CAShapeLayer()
        arrowLayer.strokeColor = UIColor.white.cgColor
        arrowLayer.lineWidth = 2
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = UIColor.clear.cgColor
        arrowLayer.lineJoin = CAShapeLayerLineJoin.round
        arrowLayer.lineCap = CAShapeLayerLineCap.round
        layer.addSublayer(arrowLayer)
//        layer.masksToBounds = true
    }
}

extension UIBezierPath {
    static func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
        let points: [CGPoint] = [
            p(0, tailWidth / 2),
            p(tailLength, tailWidth / 2),
            p(tailLength, headWidth / 2),
            p(length, 0),
            p(tailLength, -headWidth / 2),
            p(tailLength, -tailWidth / 2),
            p(0, -tailWidth / 2)
        ]

        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }

    static func arrowLTR(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
        let points: [CGPoint] = [
            p(headWidth, 0),
            p(0, headWidth / 2),
            p(tailLength, headWidth / 2),
            p(tailLength, headWidth / 2),
            p(length + headWidth, 0),
            p(length - headWidth, -headWidth / 2),
            p(length - headWidth, -headWidth / 2),
            p(0, -headWidth / 2)
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
