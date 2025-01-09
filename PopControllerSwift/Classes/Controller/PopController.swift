//
//  PopController.swift
//  PopController
//
//  Created by hb on 2025/1/9.
//

import Foundation
import UIKit

/// PopController manages the presentation and dismissal of custom view controllers in a popup style.
///
/// This controller provides various animation styles and positioning options for presenting view controllers
/// in a popup manner. It also handles keyboard events and screen rotation automatically.
///
/// # Important Notes
/// When dismissing the popup in your custom view controller, you must use one of these methods:
/// ```swift
/// // Option 1: Using dismissPop
/// dismissPop(animated: true) {
///     // Your completion handler
/// }
///
/// // Option 2: Using popController directly
/// popController?.dismiss(completion: {
///     // Your completion handler
/// })
/// ```
///
/// # Implementation Note
/// Unlike Objective-C, Swift doesn't support method swizzling out of the box, which makes it impossible
/// to automatically intercept and override the standard UIKit `dismiss(animated:completion:)` method.
/// This is why we need to explicitly use our custom dismiss methods to ensure proper cleanup and
/// memory management. While this approach may seem less elegant than automatic method interception,
/// it provides better type safety and code clarity.
///
/// # Features
/// - Multiple animation styles for presentation and dismissal
/// - Customizable positioning and offset
/// - Automatic keyboard handling
/// - Background touch dismissal
/// - Safe area support
public class PopController: NSObject {
    
    // MARK: - Static Properties
    private static var retainedPopControllers = Set<PopController>()
    
    // MARK: - Config Properties
    public var popType: PopType = .growIn
    public var dismissType: DismissType = .fadeOut
    public var animationDuration: TimeInterval = 0.2
    public var popPosition: PopPosition = .center
    public var positionOffset: CGPoint = .zero
    public weak var animationProtocol: PopControllerAnimationProtocol?
    public var safeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            didOverrideSafeAreaInsets = true
        }
    }
    
    private var _backgroundView: UIView?
    public var backgroundView: UIView {
        get {
            if _backgroundView == nil {
                let view = UIView()
                view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView)))
                _backgroundView = view
            }
            return _backgroundView!
        }
        set {
            _backgroundView?.removeFromSuperview()
            _backgroundView = newValue
            newValue.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView)))
            containerViewController.view.insertSubview(newValue, at: 0)
        }
    }
    
    public var backgroundAlpha: CGFloat = 0.5 {
        didSet {
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(backgroundAlpha)
        }
    }
    
    public var shouldDismissOnBackgroundTouch: Bool = true
    public var shouldAutoHandleKeyboardEvent: Bool = true
    
    // MARK: - Private Properties
    private var transitioningDelegate: PopTransitioningDelegate?
    private lazy var containerViewController: PopContainerViewController = {
        let containerViewController = PopContainerViewController()
        containerViewController.modalPresentationStyle = .custom
        transitioningDelegate = PopTransitioningDelegate(popController: self)
        containerViewController.transitioningDelegate = transitioningDelegate
        return containerViewController
    }()
    
    private var didOverrideSafeAreaInsets: Bool = false
    private var isObserving: Bool = false
    private var keyboardInfo: [AnyHashable: Any]?
    
    // MARK: - Public Readonly Properties
    private(set) public var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    private(set) public var contentView: UIView = UIView()
    private(set) public var topViewController: UIViewController
    public var presented: Bool {
        return containerViewController.presentingViewController != nil
    }
    
    // MARK: - Initialization
    public init(presenting viewController: UIViewController) {
        self.topViewController = viewController
        super.init()
        PopController.retainedPopControllers.insert(self)
        viewController.popController = self
        
        setup()
    }
    
    deinit {
        destroyObserver()
        destroyObserverForViewController(topViewController)
        PopController.retainedPopControllers.remove(self)
    }
    
    // MARK: - Public Methods
    public func present(in presentingViewController: UIViewController) {
        present(in: presentingViewController, completion: nil)
    }
    
    public func present(in presentingViewController: UIViewController, completion: (() -> Void)?) {
        guard !presented else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            setupObserver()
            setupObserverForViewController(topViewController)
            
            let vc = presentingViewController.tabBarController ?? presentingViewController
            
            if #available(iOS 11.0, *) {
                if (!self.didOverrideSafeAreaInsets) {
                    self.safeAreaInsets = presentingViewController.view.safeAreaInsets
                }
            }
            
            vc.present(self.containerViewController, animated: true, completion: completion)
        }
    }
    
    public func dismiss() {
        dismiss(completion: nil)
    }
    
    public func dismiss(completion: (() -> Void)?) {
        guard presented else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.destroyObserver()
            self.containerViewController.dismiss(animated: true) {
                PopController.retainedPopControllers.remove(self)
                completion?()
            }
        }
    }
    
    public func layoutContainerView() {
        let lastTransform = containerView.transform
        containerView.transform = .identity
        
        backgroundView.frame = containerViewController.view.bounds
        
        let contentSize = contentSizeOfTopView()
        let containerViewWidth = contentSize.width
        var containerViewHeight = contentSize.height
        var containerViewY: CGFloat
        
        switch popPosition {
        case .bottom:
            containerViewHeight += safeAreaInsets.bottom
            containerViewY = containerViewController.view.bounds.height - containerViewHeight
        case .top:
            containerViewY = 0
        default:
            containerViewY = (containerViewController.view.bounds.height - containerViewHeight) / 2
        }
        
        containerViewY += positionOffset.y
        let containerViewX = (containerViewController.view.bounds.width - containerViewWidth) / 2 + positionOffset.x
        
        containerView.frame = CGRect(x: containerViewX, y: containerViewY, width: containerViewWidth, height: containerViewHeight)
        contentView.frame = CGRect(origin: .zero, size: contentSize)
        topViewController.view.frame = contentView.bounds
        
        containerView.transform = lastTransform
    }
    
    // MARK: - Private Methods
    private func setup() {
        shouldDismissOnBackgroundTouch = true
        shouldAutoHandleKeyboardEvent = true
        animationDuration = 0.2
        popType = .growIn
        dismissType = .fadeOut
        
        containerViewController.view.addSubview(containerView)
        containerView.addSubview(contentView)
        
        let bgView = UIView()
        backgroundView = bgView
        backgroundAlpha = 0.5
    }
}

extension PopController {
    // MARK: - Observer Methods
    private func setupObserverForViewController(_ viewController: UIViewController) {
        viewController.addObserver(self, 
                                 forKeyPath: "contentSizeInPop", 
                                 options: .new, 
                                 context: nil)
        viewController.addObserver(self, 
                                 forKeyPath: "contentSizeInPopWhenLandscape", 
                                 options: .new, 
                                 context: nil)
    }
    
    private func setupObserver() {
        guard !isObserving else { return }
        
        // 观察屏幕旋转
        NotificationCenter.default.addObserver(self, 
                                            selector: #selector(orientationDidChange), 
                                               name: UIApplication.didChangeStatusBarOrientationNotification,
                                            object: nil)
        
        if shouldAutoHandleKeyboardEvent {
            // 观察键盘事件
            NotificationCenter.default.addObserver(self, 
                                                selector: #selector(keyboardWillShow(_:)), 
                                                name: UIResponder.keyboardWillShowNotification, 
                                                object: nil)
            NotificationCenter.default.addObserver(self, 
                                                selector: #selector(keyboardWillShow(_:)), 
                                                name: UIResponder.keyboardWillChangeFrameNotification, 
                                                object: nil)
            NotificationCenter.default.addObserver(self, 
                                                selector: #selector(keyboardWillHide(_:)), 
                                                name: UIResponder.keyboardWillHideNotification, 
                                                object: nil)
        }
        
        isObserving = true
    }
    
    private func destroyObserver() {
        guard isObserving else { return }
        NotificationCenter.default.removeObserver(self)
        isObserving = false
    }
    
    private func destroyObserverForViewController(_ viewController: UIViewController) {
        viewController.removeObserver(self, forKeyPath: "contentSizeInPop")
        viewController.removeObserver(self, forKeyPath: "contentSizeInPopWhenLandscape")
    }
    
    // MARK: - KVO
    public override func observeValue(forKeyPath keyPath: String?, 
                                    of object: Any?, 
                                    change: [NSKeyValueChangeKey : Any]?, 
                                    context: UnsafeMutableRawPointer?) {
        if object as? UIViewController == topViewController {
            if topViewController.isViewLoaded && topViewController.view.superview != nil {
                UIView.animate(withDuration: 0.35, 
                             delay: 0, 
                             usingSpringWithDamping: 1, 
                             initialSpringVelocity: 0, 
                             options: .curveEaseIn) {
                    self.layoutContainerView()
                } completion: { _ in
                    self.adjustContainerViewOrigin()
                }
            }
        }
    }
    
    // MARK: - Screen Rotation
    @objc private func orientationDidChange() {
        containerView.endEditing(true)
        UIView.animate(withDuration: 0.25) {
            self.layoutContainerView()
        }
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard shouldAutoHandleKeyboardEvent,
              let currentTextInput = getCurrentTextInput(in: containerView) else { return }
        
        keyboardInfo = notification.userInfo ?? [:]
        adjustContainerViewOrigin()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard shouldAutoHandleKeyboardEvent else { return }
        
        keyboardInfo = nil
        
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let curve = UIView.AnimationCurve(rawValue: curveValue) else { return }
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationDuration(duration)
        
        containerView.transform = .identity
        
        UIView.commitAnimations()
    }
    
    private func adjustContainerViewOrigin() {
        guard let keyboardInfo = keyboardInfo,
              let currentTextInput = getCurrentTextInput(in: containerView) else { return }
        
        let lastTransform = containerView.transform
        containerView.transform = .identity
        
        let textFieldBottomY = currentTextInput.convert(.zero, to: containerViewController.view).y + currentTextInput.bounds.height
        guard let keyboardFrame = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        var keyboardHeight = keyboardFrame.height
        
        // iOS 7 兼容处理
        if #available(iOS 8.0, *) {} else {
            let orientation = UIApplication.shared.statusBarOrientation
            if orientation.isLandscape {
                keyboardHeight = keyboardFrame.width
            }
        }
        
        var offsetY: CGFloat = 0
        if popPosition == .bottom {
            offsetY = keyboardHeight - safeAreaInsets.bottom
        } else {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            if containerView.bounds.height <= containerViewController.view.bounds.height - keyboardHeight - statusBarHeight {
                offsetY = containerView.frame.origin.y - (statusBarHeight + (containerViewController.view.bounds.height - keyboardHeight - statusBarHeight - containerView.bounds.height) / 2)
            } else {
                let spacing: CGFloat = 5
                offsetY = containerView.frame.origin.y + containerView.bounds.height - (containerViewController.view.bounds.height - keyboardHeight - spacing)
                if offsetY <= 0 { return }
                
                if containerView.frame.origin.y - offsetY < statusBarHeight {
                    offsetY = containerView.frame.origin.y - statusBarHeight
                    if textFieldBottomY - offsetY > containerViewController.view.bounds.height - keyboardHeight - spacing {
                        offsetY = textFieldBottomY - (containerViewController.view.bounds.height - keyboardHeight - spacing)
                    }
                }
            }
        }
        
        guard let duration = keyboardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = keyboardInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let curve = UIView.AnimationCurve(rawValue: curveValue) else { return }
        
        containerView.transform = lastTransform
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationDuration(duration)
        
        containerView.transform = CGAffineTransform(translationX: 0, y: -offsetY)
        
        UIView.commitAnimations()
    }
    
    private func getCurrentTextInput(in view: UIView) -> UIView? {
        if let textInput = view as? UITextInput, view.isFirstResponder {
            // 修复 web view 问题
            if !["UIWebBrowserView", "WKContentView"].contains(type(of: view).description()) {
                return view
            }
        }
        
        for subview in view.subviews {
            if let textInput = getCurrentTextInput(in: subview) {
                return textInput
            }
        }
        return nil
    }
    
    private func contentSizeOfTopView() -> CGSize {
        var contentSize: CGSize
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft, .landscapeRight:
            contentSize = topViewController.contentSizeInPopWhenLandscape
            if contentSize == .zero {
                contentSize = topViewController.contentSizeInPop
            }
        default:
            contentSize = topViewController.contentSizeInPop
        }
        
        assert(!contentSize.equalTo(.zero), "contentSizeInPop should not be zero size.")
        return contentSize
    }
    
    @objc private func didTapBackgroundView() {
        if shouldDismissOnBackgroundTouch {
            dismiss()
        }
    }
}

fileprivate class PopContainerViewController: UIViewController {
    
}
