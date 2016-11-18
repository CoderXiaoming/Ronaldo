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
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval{
        return 0.5
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
        toView.tintAdjustmentMode = UIViewTintAdjustmentMode.Normal
        toView.userInteractionEnabled = true
        
        let fromView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!.view
        
        let subViews = transitionContext.containerView().subviews as NSArray
        
        var dimmingView: UIView?
        subViews.enumerateObjectsUsingBlock { (obj, idx, stop) in
            let view = obj as! UIView
            if view.layer.opacity < 1 {
                dimmingView = view
                return
            }
        
        let opacityAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        opacityAnimation.toValue = 0.0
        
        let offscreenAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        offscreenAnimation.toValue = -fromView.layer.position.y
        offscreenAnimation.completionBlock = {(anim: POPAnimation!, finished: Bool) in
            transitionContext.completeTransition(true)
        }
        
        fromView.layer.pop_addAnimation(offscreenAnimation, forKey: "offscreenAnimation")
        dimmingView!.layer.pop_addAnimation(opacityAnimation, forKey: "opacityAnimation")
    }
}
}
