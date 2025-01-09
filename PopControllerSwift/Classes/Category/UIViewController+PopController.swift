//
//  UIViewController+PopController.swift
//  PopController
//
//  Created by hb on 2025/1/9.
//

import Foundation
import UIKit

// 添加在extension之前，用于自动执行的属性包装器
@propertyWrapper
struct RuntimeInitialize<T> {
    let wrappedValue: T
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        UIViewController.swizzleMethods()
    }
}

// Property wrapper for associated object storage
@propertyWrapper
struct AssociatedObject<T> {
    let key: UnsafeRawPointer
    let defaultValue: T
    
    init(_ key: UnsafeRawPointer, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            (objc_getAssociatedObject(self, key) as? T) ?? defaultValue
        }
        set {
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// Move AssociatedObject wrapper outside and create a helper class
private class AssociatedKeys {
    static let contentSizeKey = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let contentSizeLandscapeKey = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let popControllerKey = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    
    static func getAssociatedObject<T>(_ object: Any, key: UnsafeRawPointer, defaultValue: T) -> T {
        return (objc_getAssociatedObject(object, key) as? T) ?? defaultValue
    }
    
    static func setAssociatedObject<T>(_ object: Any, key: UnsafeRawPointer, value: T) {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension UIViewController {
    // 使用属性包装器确保方法交换的自动执行
    @RuntimeInitialize
    private static var swizzleToken: Void = ()
    
    internal static func swizzleMethods() {
        hw_swizzleInstanceMethod(originalSel: #selector(viewDidLoad),
                                   with: #selector(hw_viewDidLoad))
        
        hw_swizzleInstanceMethod(originalSel: #selector(present(_:animated:completion:)),
                                   with: #selector(hw_present(_:animated:completion:)))
        
        hw_swizzleInstanceMethod(originalSel: #selector(dismiss(animated:completion:)),
                                   with: #selector(hw_dismiss(animated:completion:)))
    }
    
    // Add the swizzled methods here
    @objc private func hw_viewDidLoad() {
        hw_viewDidLoad()
        
        let contentSize: CGSize
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft, .landscapeRight:
            contentSize = contentSizeInPopWhenLandscape.equalTo(.zero) ? contentSizeInPop : contentSizeInPopWhenLandscape
        default:
            contentSize = contentSizeInPop
        }
        
        if !contentSize.equalTo(.zero) {
            view.frame = CGRect(origin: .zero, size: contentSize)
        }
    }
    
    @objc private func hw_present(_ viewControllerToPresent: UIViewController,
                                 animated flag: Bool,
                                 completion: (() -> Void)? = nil) {
        guard let popController = self.popController,
              let containerViewController = popController.value(forKey: "containerViewController") as? UIViewController else {
            hw_present(viewControllerToPresent, animated: flag, completion: completion)
            return
        }
        
        containerViewController.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    @objc private func hw_dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let popController = self.popController else {
            hw_dismiss(animated: flag, completion: completion)
            return
        }
        
        popController.dismiss(completion: completion)
    }
    
    // MARK: - Properties
    private struct AssociatedKeys {
        static var contentSizeInPopKey = "contentSizeInPopKey"
        static var contentSizeInPopWhenLandscapeKey = "contentSizeInPopWhenLandscapeKey"
        static var popControllerKey = "popControllerKey"
    }
    
    @objc public var contentSizeInPop: CGSize {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.contentSizeInPopKey) as? CGSize) ?? .zero
        }
        set {
            willChangeValue(forKey: "contentSizeInPop")
            var size = newValue
            if !size.equalTo(.zero) && abs(size.width) < .ulpOfOne {
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
            if !size.equalTo(.zero) && abs(size.width) < .ulpOfOne {
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
    
    @discardableResult
    func popup() -> PopController {
        return popupWith(popType: .growIn,
                        dismissType: .fadeOut,
                        position: .center,
                        inViewController: UIViewController.getTopMostViewController(),
                        dismissOnBackgroundTouch: true)
    }
    
    @discardableResult
    func popupWith(popType: PopType, dismissType: DismissType) -> PopController {
        return popupWith(popType: popType,
                        dismissType: dismissType,
                        position: .center)
    }
    
    @discardableResult
    func popupWith(popType: PopType,
                   dismissType: DismissType,
                   position: PopPosition) -> PopController {
        return popupWith(popType: popType,
                        dismissType: dismissType,
                        position: position,
                        inViewController: UIViewController.getTopMostViewController(),
                        dismissOnBackgroundTouch: true)
    }
    
    @discardableResult
    func popupWith(popType: PopType,
                   dismissType: DismissType,
                   position: PopPosition,
                   dismissOnBackgroundTouch: Bool) -> PopController {
        return popupWith(popType: popType,
                        dismissType: dismissType,
                        position: position,
                        inViewController: UIViewController.getTopMostViewController(),
                        dismissOnBackgroundTouch: dismissOnBackgroundTouch)
    }
    
    @discardableResult
    func popupWith(popType: PopType,
                   dismissType: DismissType,
                   position: PopPosition,
                   inViewController: UIViewController,
                   dismissOnBackgroundTouch: Bool) -> PopController {
        let popController = PopController(viewController: self)
        popController.popType = popType
        popController.dismissType = dismissType
        popController.popPosition = position
        popController.shouldDismissOnBackgroundTouch = dismissOnBackgroundTouch
        popController.present(in: inViewController)
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
