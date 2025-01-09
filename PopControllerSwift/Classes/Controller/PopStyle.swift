//
//  enum.swift
//  PopController-iOS13.0
//
//  Created by hb on 2025/1/9.
//

import Foundation

// Position of the popup view
public enum PopPosition: Int {
    case center
    case top
    case bottom
}

// State of the popup view
public enum PopState: Int {
    case pop        // present
    case dismiss    // dismiss
}

// Animation types for popup
public enum PopType: Int {
    case none
    case fadeIn
    case growIn
    case shrinkIn
    case slideInFromTop
    case slideInFromBottom
    case slideInFromLeft
    case slideInFromRight
    case bounceIn
    case bounceInFromTop
    case bounceInFromBottom
    case bounceInFromLeft
    case bounceInFromRight
}

// Animation types for dismissal
public enum DismissType: Int {
    case none
    case fadeOut
    case growOut
    case shrinkOut
    case slideOutToTop
    case slideOutToBottom
    case slideOutToLeft
    case slideOutToRight
    case bounceOut
    case bounceOutToTop
    case bounceOutToBottom
    case bounceOutToLeft
    case bounceOutToRight
}
