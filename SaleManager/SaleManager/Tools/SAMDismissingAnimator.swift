//
//  SAMDismissingAnimator.swift
//  SaleManager
//
//  Created by apple on 16/11/18.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import pop

class SAMDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view
        toView?.tintAdjustmentMode = UIViewTintAdjustmentMode.normal
        toView?.isUserInteractionEnabled = true
        
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view!
        
        let subViews = transitionContext.containerView.subviews as NSArray
        
        var dimmingView: UIView?
        subViews.enumerateObjects({ (obj, idx, stop) in
            let view = obj as! UIView
            if view.layer.opacity < 1 {
                dimmingView = view
                return
            }
            
            let opacityAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)!
            opacityAnimation.toValue = 0.0
            
            let offscreenAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)!
            offscreenAnimation.toValue = -fromView.layer.position.y
            offscreenAnimation.completionBlock = {(anim: POPAnimation?, finished: Bool) in
                transitionContext.completeTransition(true)
            }
            
            fromView.layer.pop_add(offscreenAnimation, forKey: "offscreenAnimation")
            dimmingView!.layer.pop_add(opacityAnimation, forKey: "opacityAnimation")
        })
}
}
