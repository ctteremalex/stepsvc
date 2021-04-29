//
//  RMSeperatorView.swift
//  step
//
//  Created by Mihail Terekhov on 22.04.2021.
//

import UIKit

class RMStepSeperatorView: UIView, CAAnimationDelegate {
    
    private let AnimationKey = "fillColor"
    private let AnimationDuration: CFTimeInterval = 0.3

    private lazy var leftShapeLayer: CAShapeLayer = {
        let newLayer = CAShapeLayer()
        newLayer.removeAnimation(forKey: AnimationKey)
        return newLayer
    }()
    private lazy var rightShapeLayer: CAShapeLayer = {
        let newLayer = CAShapeLayer()
        newLayer.removeAnimation(forKey: AnimationKey)
        return newLayer
    }()
    public lazy var seperatorColor: UIColor = UIColor(white: 0, alpha: 0.3)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        layer.addSublayer(leftShapeLayer)
        layer.addSublayer(rightShapeLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let leftBezier = UIBezierPath()
        leftBezier.move(to: .zero)
        leftBezier.addLine(to: CGPoint(x: frame.width, y: ceil(frame.height / 2)))
        leftBezier.addLine(to: CGPoint(x: 0, y: frame.height))
        leftBezier.close()
        
        leftShapeLayer.path = leftBezier.cgPath
        leftShapeLayer.bounds = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        leftShapeLayer.anchorPoint = .zero
        leftShapeLayer.position = .zero
        
        let rightBezier = UIBezierPath()
        rightBezier.move(to: .zero)
        rightBezier.addLine(to: CGPoint(x: frame.width - 0.5, y: (frame.height / 2)))
        rightBezier.addLine(to: CGPoint(x: 0, y: frame.height))
        rightBezier.addLine(to: CGPoint(x: frame.width, y: frame.height))
        rightBezier.addLine(to: CGPoint(x: frame.width, y: 0))
        rightBezier.close()
        
        rightShapeLayer.path = rightBezier.cgPath
        rightShapeLayer.bounds = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        rightShapeLayer.anchorPoint = .zero
        rightShapeLayer.position = .zero
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bezier = UIBezierPath()
        bezier.lineWidth = 0.5
        bezier.lineJoinStyle = .bevel
        
        bezier.move(to: .zero)
        bezier.addLine(to: CGPoint(x: frame.width - 0.5, y: ceil(frame.height / 2)))
        bezier.addLine(to: CGPoint(x: 0, y: frame.height))
        
        seperatorColor.setStroke()
        bezier.stroke()
    }
    
    public func setupLeftColor(leftColor: UIColor, animated: Bool) {
        if (!animated) {
            leftShapeLayer.fillColor = leftColor.cgColor
            return
        }
        
        let fillColorAnimation = createBasicAnimation()
        fillColorAnimation.fromValue = leftShapeLayer.presentation()?.value(forKey: AnimationKey)
        fillColorAnimation.toValue = leftColor.cgColor
        leftShapeLayer.add(fillColorAnimation, forKey: AnimationKey)
    }
    
    public func setupRightColor(rightColor: UIColor, animated: Bool) {
        if (!animated) {
            rightShapeLayer.fillColor = rightColor.cgColor
            return
        }
        
        let fillColorAnimation = createBasicAnimation()
        fillColorAnimation.fromValue = rightShapeLayer.presentation()?.value(forKey: AnimationKey)
        fillColorAnimation.toValue = rightColor.cgColor
        rightShapeLayer.add(fillColorAnimation, forKey: AnimationKey)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if (!flag) {
            return
        }
        
        guard let basicAnim = anim as? CABasicAnimation else {
            return
        }
        
        if basicAnim == leftShapeLayer.animation(forKey: AnimationKey) {
            leftShapeLayer.fillColor = basicAnim.toValue as! CGColor
            return
        }
        
        if basicAnim == rightShapeLayer.animation(forKey: AnimationKey) {
            leftShapeLayer.fillColor = basicAnim.toValue as! CGColor
            return
        }
    }
    
    private func createBasicAnimation() -> CABasicAnimation {
        let newAnimation = CABasicAnimation(keyPath: AnimationKey)
        
        newAnimation.duration = AnimationDuration
        newAnimation.delegate = self
        newAnimation.isRemovedOnCompletion = false
        newAnimation.fillMode = .forwards
        newAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        return newAnimation
    }
    
}
