//
//  PopTransitioningDelegate.swift
//  PopController
//
//  Created by heath wang on 2025/1/9.
//

import UIKit

class PopTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private(set) weak var popController: PopController?
    
    init(popController: PopController) {
        self.popController = popController
        super.init()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let popController = popController else { return nil }
        return PopControllerAnimatedTransitioning(state: .pop, popController: popController)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let popController = popController else { return nil }
        return PopControllerAnimatedTransitioning(state: .dismiss, popController: popController)
    }
}
