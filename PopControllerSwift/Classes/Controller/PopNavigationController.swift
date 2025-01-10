//
//  PopNavigationController.swift
//  PopControllerSwift
//
//  Created by hb on 2025/1/10.
//

import Foundation
import UIKit

open class PopNavigationController: UINavigationController {
    
    var originContentSizeInPop: CGSize?
    var originContentSizeInPopWhenLandscape: CGSize?
    
    public var useSystemAnimatedTransitioning = false
    
    private var animatedTransitioning = NavAnimatedTransitioning(state: .pop)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        originContentSizeInPop = contentSizeInPop
        originContentSizeInPopWhenLandscape = contentSizeInPopWhenLandscape
    }
    
    func adjustContentSizeBy(_ viewController: UIViewController) {
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft, .landscapeRight:
            let contentSizeInPopWhenLandscape = viewController.contentSizeInPopWhenLandscape
            if !CGSizeEqualToSize(contentSizeInPopWhenLandscape, .zero) {
                self.contentSizeInPopWhenLandscape = contentSizeInPopWhenLandscape
            } else {
                self.contentSizeInPopWhenLandscape = originContentSizeInPopWhenLandscape!
            }
            
        default:
            let contentSizeInPop = viewController.contentSizeInPop
            if !CGSizeEqualToSize(contentSizeInPop, .zero) {
                self.contentSizeInPop = contentSizeInPop
            } else {
                self.contentSizeInPop = originContentSizeInPop!
            }
        }
    }
}

extension PopNavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        _ =  toVC.view
        adjustContentSizeBy(toVC)
        animatedTransitioning.setState(operation == .push ? .pop : .dismiss)
        if useSystemAnimatedTransitioning {
            return nil
        }
        return animatedTransitioning
    }
}
