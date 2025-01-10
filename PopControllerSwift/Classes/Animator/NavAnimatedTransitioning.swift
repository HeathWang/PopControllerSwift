import UIKit

class NavAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var state: PopState
    
    init(state: PopState) {
        self.state = state
        super.init()
    }
    
    public func setState(_ state: PopState) {
        self.state = state
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.15
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        if state == .pop {
            let finalFrame = transitionContext.finalFrame(for: toVC)
            toVC.view.frame = finalFrame
            transitionContext.containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        } else {
            transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        
        fromVC.view.alpha = 1
        toVC.view.alpha = 0
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveLinear,
            animations: {
                fromVC.view.alpha = 0
                toVC.view.alpha = 1
            }, completion: { _ in
                transitionContext.completeTransition(true)
                fromVC.view.alpha = 1
            }
        )
    }
}
