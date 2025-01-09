import UIKit

public class PopAnimationContext {
    private(set) var state: PopState
    private(set) var containerView: UIView
    var duration: TimeInterval = 0.0
    var springAnimationConfig = SpringAnimationConfig(damping: 0.8, velocity: 10)
    
    init(state: PopState, containerView: UIView) {
        self.state = state
        self.containerView = containerView
    }
}
