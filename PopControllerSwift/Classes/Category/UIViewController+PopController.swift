//
//  UIViewController+PopController.swift
//  PopController
//
//  Created by hb on 2025/1/9.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: - Properties
    private struct AssociatedKeys {
        static var contentSizeInPopKey: Void?
        static var contentSizeInPopWhenLandscapeKey: Void?
        static var popControllerKey: Void?
    }
    
    @objc public var contentSizeInPop: CGSize {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.contentSizeInPopKey) as? CGSize) ?? .zero
        }
        set {
            willChangeValue(forKey: "contentSizeInPop")
            var size = newValue
            if (!size.equalTo(.zero) && abs(size.width) < .ulpOfOne) {
                let orientation = UIApplication.shared.statusBarOrientation
                let screenBounds = UIScreen.main.bounds
                size.width = orientation.isLandscape ? screenBounds.height : screenBounds.width
            }
            objc_setAssociatedObject(self, &AssociatedKeys.contentSizeInPopKey, size, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: "contentSizeInPop")
        }
    }
    
    @objc public var contentSizeInPopWhenLandscape: CGSize {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.contentSizeInPopWhenLandscapeKey) as? CGSize) ?? .zero
        }
        set {
            willChangeValue(forKey: "contentSizeInPopWhenLandscape")
            var size = newValue
            if (!size.equalTo(.zero) && abs(size.width) < .ulpOfOne) {
                let orientation = UIApplication.shared.statusBarOrientation
                let screenBounds = UIScreen.main.bounds
                size.width = orientation.isLandscape ? screenBounds.width : screenBounds.height
            }
            objc_setAssociatedObject(self, &AssociatedKeys.contentSizeInPopWhenLandscapeKey, size, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: "contentSizeInPopWhenLandscape")
        }
    }
    
    public var popController: PopController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.popControllerKey) as? PopController
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.popControllerKey,
                newValue,
                .OBJC_ASSOCIATION_ASSIGN
            )
        }
    }
}

// MARK: - Pop Extensions
public extension UIViewController {
    
    func dismissPop(animated flag: Bool, completion: (() -> Void)? = nil) {
        // Clean up popController if exists
        if let popController = self.popController {
            popController.dismiss(completion: completion)
            return
        }
        
        dismiss(animated: flag, completion: completion)
    }
    
    @discardableResult
    func present(asPopup: Bool = true) -> PopController {
        return present(using: .growIn,
                      dismissWith: .fadeOut,
                      at: .center,
                      in: UIViewController.getTopMostViewController(),
                      dismissOnBackgroundTouch: true)
    }
    
    @discardableResult
    func present(using popType: PopType, dismissWith dismissType: DismissType) -> PopController {
        return present(using: popType,
                      dismissWith: dismissType,
                      at: .center)
    }
    
    @discardableResult
    func present(using popType: PopType,
                 dismissWith dismissType: DismissType,
                 at position: PopPosition) -> PopController {
        return present(using: popType,
                      dismissWith: dismissType,
                      at: position,
                      in: UIViewController.getTopMostViewController(),
                      dismissOnBackgroundTouch: true)
    }
    
    @discardableResult
    func present(using popType: PopType,
                 dismissWith dismissType: DismissType,
                 at position: PopPosition,
                 dismissOnBackgroundTouch: Bool) -> PopController {
        return present(using: popType,
                      dismissWith: dismissType,
                      at: position,
                      in: UIViewController.getTopMostViewController(),
                      dismissOnBackgroundTouch: dismissOnBackgroundTouch)
    }
    
    @discardableResult
    func present(using popType: PopType,
                 dismissWith dismissType: DismissType,
                 at position: PopPosition,
                 in viewController: UIViewController,
                 dismissOnBackgroundTouch: Bool) -> PopController {
        let popController = PopController(presenting: self)
        popController.popType = popType
        popController.dismissType = dismissType
        popController.popPosition = position
        popController.shouldDismissOnBackgroundTouch = dismissOnBackgroundTouch
        popController.present(in: viewController)
        return popController
    }
    
    private static func getTopMostViewController() -> UIViewController {
        guard let keyWindow = UIApplication.shared.keyWindow,
              var topVC = keyWindow.rootViewController else { return UIViewController() }
        
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        
        if let navController = topVC as? UINavigationController {
            topVC = navController.topViewController ?? topVC
        }
        
        if let tabController = topVC as? UITabBarController {
            topVC = tabController.selectedViewController ?? topVC
        }
        
        return topVC
    }
}
