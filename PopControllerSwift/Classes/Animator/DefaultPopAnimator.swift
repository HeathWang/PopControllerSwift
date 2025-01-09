import UIKit

public class DefaultPopAnimator: NSObject, PopControllerAnimationProtocol {
    
    public var popType: PopType = .none
    public var dismissType: DismissType = .none
    
    
    public func popControllerAnimationDuration(_ context: PopAnimationContext) -> TimeInterval {
        return context.duration > 0 ? context.duration : 0.2
    }
    
    public func popAnimate(_ context: PopAnimationContext, completion: @escaping (Bool) -> Void) {
        let duration = popControllerAnimationDuration(context)
        let containerView = context.containerView
        let springConfig = context.springAnimationConfig
        
        switch popType {
        case .fadeIn:
            containerView.transform = .identity
            containerView.alpha = 0
            UIView.animate(withDuration: duration) {
                containerView.alpha = 1
            } completion: { finished in
                completion(finished)
            }
            
        case .growIn:
            containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            containerView.alpha = 0
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.transform = .identity
                containerView.alpha = 1
            } completion: { finished in
                completion(finished)
            }
            
        case .shrinkIn:
            containerView.alpha = 0
            containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.alpha = 1
                containerView.transform = .identity
            } completion: { finished in
                completion(finished)
            }
            
        case .slideInFromTop:
            containerView.alpha = 1
            containerView.transform = .identity
            let originFrame = containerView.frame
            var rect = containerView.frame
            rect.origin.y = -originFrame.height - 20
            containerView.frame = rect
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.frame = originFrame
            } completion: { finished in
                completion(finished)
            }
            
        case .slideInFromBottom:
            containerView.alpha = 1
            containerView.transform = .identity
            let originFrame = containerView.frame
            var rect = containerView.frame
            rect.origin.y = containerView.superview?.frame.height ?? 0
            containerView.frame = rect
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.frame = originFrame
            } completion: { finished in
                completion(finished)
            }
            
        case .slideInFromLeft:
            containerView.alpha = 1
            containerView.transform = .identity
            let originFrame = containerView.frame
            var rect = containerView.frame
            rect.origin.x = -rect.width
            containerView.frame = rect
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.frame = originFrame
            } completion: { finished in
                completion(finished)
            }
            
        case .slideInFromRight:
            containerView.alpha = 1
            containerView.transform = .identity
            let originFrame = containerView.frame
            var rect = containerView.frame
            rect.origin.x = containerView.superview?.frame.width ?? 0
            containerView.frame = rect
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.frame = originFrame
            } completion: { finished in
                completion(finished)
            }
            
        case .bounceIn:
            containerView.transform = .identity
            containerView.alpha = 0
            containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: duration,
                         delay: 0,
                           usingSpringWithDamping: springConfig.damping,
                           initialSpringVelocity: springConfig.velocity) {
                containerView.alpha = 1
                containerView.transform = .identity
            } completion: { finished in
                completion(finished)
            }
            
        case .bounceInFromTop:
            containerView.alpha = 1
            containerView.transform = .identity
            let originFrame = containerView.frame
            var rect = containerView.frame
            rect.origin.y = -originFrame.height
            containerView.frame = rect
            UIView.animate(withDuration: duration,
                         delay: 0,
                           usingSpringWithDamping: springConfig.damping,
                           initialSpringVelocity: springConfig.velocity) {
                containerView.frame = originFrame
            } completion: { finished in
                completion(finished)
            }
            
        case .bounceInFromBottom:
            containerView.alpha = 1
            containerView.transform = .identity
            let originFrame = containerView.frame
            var rect = containerView.frame
            rect.origin.y = containerView.superview?.frame.height ?? 0
            containerView.frame = rect
            UIView.animate(withDuration: duration,
                         delay: 0,
                           usingSpringWithDamping: springConfig.damping,
                           initialSpringVelocity: springConfig.velocity) {
                containerView.frame = originFrame
            } completion: { finished in
                completion(finished)
            }
            
        case .bounceInFromLeft:
            containerView.alpha = 1
            containerView.transform = .identity
            let originFrame = containerView.frame
            var rect = containerView.frame
            rect.origin.x = -rect.width
            containerView.frame = rect
            UIView.animate(withDuration: duration,
                         delay: 0,
                           usingSpringWithDamping: springConfig.damping,
                           initialSpringVelocity: springConfig.velocity) {
                containerView.frame = originFrame
            } completion: { finished in
                completion(finished)
            }
            
        case .bounceInFromRight:
            containerView.alpha = 1
            containerView.transform = .identity
            let originFrame = containerView.frame
            var rect = containerView.frame
            rect.origin.x = containerView.superview?.frame.width ?? 0
            containerView.frame = rect
            UIView.animate(withDuration: duration,
                         delay: 0,
                           usingSpringWithDamping: springConfig.damping,
                           initialSpringVelocity: springConfig.velocity) {
                containerView.frame = originFrame
            } completion: { finished in
                completion(finished)
            }
            
        case .none:
            containerView.alpha = 1
            containerView.transform = .identity
            completion(true)
        }
    }
    
    public func dismissAnimate(_ context: PopAnimationContext, completion: @escaping (Bool) -> Void) {
        let duration = popControllerAnimationDuration(context)
        let bounceDuration1 = duration * 1 / 3
        let bounceDuration2 = duration * 2 / 3
        
        let containerView = context.containerView
        
        switch dismissType {
        case .fadeOut:
            containerView.transform = .identity
            UIView.animate(withDuration: duration) {
                containerView.alpha = 0
            } completion: { finished in
                completion(finished)
            }
            
        case .growOut:
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                containerView.alpha = 0
            } completion: { finished in
                completion(finished)
            }
            
        case .shrinkOut:
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.alpha = 0
                containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            } completion: { finished in
                completion(finished)
            }
            
        case .slideOutToTop:
            var rect = containerView.frame
            rect.origin.y = -rect.height
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.frame = rect
            } completion: { finished in
                completion(finished)
            }
            
        case .slideOutToBottom:
            var rect = containerView.frame
            rect.origin.y = containerView.superview?.frame.height ?? 0
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.frame = rect
            } completion: { finished in
                completion(finished)
            }
            
        case .slideOutToLeft:
            var rect = containerView.frame
            rect.origin.x = -rect.width
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.frame = rect
            } completion: { finished in
                completion(finished)
            }
            
        case .slideOutToRight:
            var rect = containerView.frame
            rect.origin.x = containerView.superview?.frame.width ?? 0
            UIView.animate(withDuration: duration,
                         delay: 0,
                         options: .curveEaseInOut) {
                containerView.frame = rect
            } completion: { finished in
                completion(finished)
            }
            
        case .bounceOut:
            UIView.animate(withDuration: bounceDuration1,
                         delay: 0,
                         options: .curveEaseOut) {
                containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                UIView.animate(withDuration: bounceDuration2,
                             delay: 0,
                             options: .curveEaseIn) {
                    containerView.alpha = 0
                    containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                } completion: { finished in
                    completion(finished)
                }
            }
            
        case .bounceOutToTop:
            var rect1 = containerView.frame
            rect1.origin.y += 20
            var rect2 = containerView.frame
            rect2.origin.y = -rect2.height
            
            UIView.animate(withDuration: bounceDuration1,
                         delay: 0,
                         options: .curveEaseOut) {
                containerView.frame = rect1
            } completion: { _ in
                UIView.animate(withDuration: bounceDuration2,
                             delay: 0,
                             options: .curveEaseIn) {
                    containerView.frame = rect2
                } completion: { finished in
                    completion(finished)
                }
            }
            
        case .bounceOutToBottom:
            var rect1 = containerView.frame
            rect1.origin.y -= 20
            var rect2 = containerView.frame
            rect2.origin.y = containerView.superview?.frame.height ?? 0
            UIView.animate(withDuration: bounceDuration1,
                         delay: 0,
                         options: .curveEaseOut) {
                containerView.frame = rect1
            } completion: { _ in
                UIView.animate(withDuration: bounceDuration2,
                             delay: 0,
                             options: .curveEaseIn) {
                    containerView.frame = rect2
                } completion: { finished in
                    completion(finished)
                }
            }
            
        case .bounceOutToLeft:
            var rect1 = containerView.frame
            rect1.origin.x += 20
            var rect2 = containerView.frame
            rect2.origin.x = -rect2.width
            
            UIView.animate(withDuration: bounceDuration1,
                         delay: 0,
                         options: .curveEaseOut) {
                containerView.frame = rect1
            } completion: { _ in
                UIView.animate(withDuration: bounceDuration2,
                             delay: 0,
                             options: .curveEaseIn) {
                    containerView.frame = rect2
                } completion: { finished in
                    completion(finished)
                }
            }
            
        case .bounceOutToRight:
            var rect1 = containerView.frame
            rect1.origin.x -= 20
            var rect2 = containerView.frame
            rect2.origin.x = containerView.superview?.frame.width ?? 0
            
            UIView.animate(withDuration: bounceDuration1,
                         delay: 0,
                         options: .curveEaseOut) {
                containerView.frame = rect1
            } completion: { _ in
                UIView.animate(withDuration: bounceDuration2,
                             delay: 0,
                             options: .curveEaseIn) {
                    containerView.frame = rect2
                } completion: { finished in
                    completion(finished)
                }
            }
            
        case .none:
            containerView.alpha = 1
            containerView.transform = .identity
            completion(true)
        }
    }
}
