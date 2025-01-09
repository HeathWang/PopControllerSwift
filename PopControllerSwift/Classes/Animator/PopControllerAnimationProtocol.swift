import UIKit

public protocol PopControllerAnimationProtocol: AnyObject {
    func popControllerAnimationDuration(_ context: PopAnimationContext) -> TimeInterval
    func popAnimate(_ context: PopAnimationContext, completion: @escaping (Bool) -> Void)
    func dismissAnimate(_ context: PopAnimationContext, completion: @escaping (Bool) -> Void)
}
