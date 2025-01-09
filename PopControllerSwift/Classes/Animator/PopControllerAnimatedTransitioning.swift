//
//  PopControllerAnimatedTransitioning.swift
//  PopController
//
//  Created by hb on 2025/1/9.
//

import Foundation
import UIKit

class PopControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    private let state: PopState
    private weak var popController: PopController?
    private let containerView: UIView
    private let backgroundView: UIView
    private let animationContext: PopAnimationContext
    private var animator: PopControllerAnimationProtocol
    
    init(state: PopState, popController: PopController) {
        self.state = state
        self.popController = popController
        self.containerView = popController.containerView
        self.backgroundView = popController.backgroundView
        self.animationContext = PopAnimationContext(state: state, containerView: containerView)
        
        // Set animation duration from popController
        self.animationContext.duration = popController.animationDuration
        self.animationContext.springAnimationConfig = popController.springConfig
        
        // Initialize animator
        if let customAnimator = popController.animationProtocol {
            self.animator = customAnimator
        } else {
            let defaultAnimator = DefaultPopAnimator()
            defaultAnimator.popType = popController.popType
            defaultAnimator.dismissType = popController.dismissType
            self.animator = defaultAnimator
        }
        
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.popControllerAnimationDuration(animationContext)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch state {
        case .pop:
            popAnimateTransition(transitionContext)
        case .dismiss:
            dismissTransition(transitionContext)
        }
    }
    
    // MARK: - Private Methods
    
    private func popAnimateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let topViewController = popController?.topViewController else { return }
        
        toViewController.view.frame = fromViewController.view.frame
        
        fromViewController.beginAppearanceTransition(false, animated: true)
        
        transitionContext.containerView.addSubview(toViewController.view)
        
        topViewController.beginAppearanceTransition(true, animated: true)
        toViewController.addChild(topViewController)
        popController?.contentView.addSubview(topViewController.view)
        
        popController?.layoutContainerView()
        
        let lastBackgroundViewAlpha = backgroundView.alpha
        backgroundView.alpha = 0
        setContainerUserInteractionEnabled(false)
        containerView.transform = .identity
        
        UIView.animate(withDuration: animator.popControllerAnimationDuration(animationContext),
                      delay: 0,
                      usingSpringWithDamping: 1,
                      initialSpringVelocity: 0,
                      options: .curveEaseInOut) {
            self.backgroundView.alpha = lastBackgroundViewAlpha
        }
        
        animator.popAnimate(animationContext) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            self.setContainerUserInteractionEnabled(true)
            
            topViewController.endAppearanceTransition()
            topViewController.didMove(toParent: toViewController)
            fromViewController.endAppearanceTransition()
            toViewController.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private func dismissTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let topViewController = popController?.topViewController else { return }
        
        toViewController.view.frame = fromViewController.view.frame
        
        toViewController.beginAppearanceTransition(true, animated: true)
        
        topViewController.beginAppearanceTransition(false, animated: true)
        topViewController.willMove(toParent: nil)
        
        let lastBackgroundViewAlpha = backgroundView.alpha
        setContainerUserInteractionEnabled(false)
        
        UIView.animate(withDuration: animator.popControllerAnimationDuration(animationContext),
                      delay: 0,
                      options: .curveEaseOut) {
            self.backgroundView.alpha = 0
        }
        
        animator.dismissAnimate(animationContext) { finished in
            self.setContainerUserInteractionEnabled(true)
            self.backgroundView.alpha = lastBackgroundViewAlpha
            
            fromViewController.view.removeFromSuperview()
            topViewController.view.removeFromSuperview()
            topViewController.removeFromParent()
            toViewController.endAppearanceTransition()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func setContainerUserInteractionEnabled(_ enabled: Bool) {
        containerView.isUserInteractionEnabled = enabled
        backgroundView.isUserInteractionEnabled = enabled
    }
}
