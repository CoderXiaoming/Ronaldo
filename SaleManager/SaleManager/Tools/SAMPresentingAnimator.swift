//
//  SAMPresentingAnimator.swift
//  SaleManager
//
//  Created by apple on 16/11/18.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import pop

class SAMPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view
        fromView?.tintAdjustmentMode = UIViewTintAdjustmentMode.dimmed
        fromView?.isUserInteractionEnabled = false
        
        let dimmingView = UIView(frame: fromView!.bounds)
        dimmingView.backgroundColor = customGrayColor
        dimmingView.layer.opacity = 0.0
        
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view
        toView?.frame = CGRect(x: 0, y: -100, width: ScreenW - 30, height: 195)
        toView!.center = CGPoint(x: transitionContext.containerView.center.x, y: -100)
        transitionContext.containerView.addSubview(dimmingView)
        transitionContext.containerView.addSubview(toView!)
        
        let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        positionAnimation?.toValue = transitionContext.containerView.center.y - 100
        positionAnimation?.springBounciness = 10
        positionAnimation?.completionBlock = {(anim: POPAnimation?, finished: Bool) in
            transitionContext.completeTransition(true)
        }
        
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnimation?.springBounciness = 20
        scaleAnimation?.fromValue = NSValue(cgPoint: CGPoint(x: 1.2, y: 1.4))
        
        let opacityAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        opacityAnimation?.toValue = 0.2
        
        toView?.layer.pop_add(positionAnimation, forKey: "positionAnimation")
        toView?.layer.pop_add(scaleAnimation, forKey: "scaleAnimation")
        dimmingView.layer.pop_add(opacityAnimation, forKey: "opacityAnimation")
    }
}
