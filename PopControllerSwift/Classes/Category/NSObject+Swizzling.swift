//
//  NSObject+Swizzling.swift
//  PopController
//
//  Created by hb on 2025/1/9.
//

import Foundation

extension NSObject {
    
    @discardableResult
    @objc class func hw_swizzleInstanceMethod(originalSel: Selector, with newSel: Selector) -> Bool {
        guard let originalMethod = class_getInstanceMethod(self, originalSel),
              let newMethod = class_getInstanceMethod(self, newSel),
              let originalImp = class_getMethodImplementation(self, originalSel),
              let newImp = class_getMethodImplementation(self, newSel) else {
            return false
        }
        
        class_addMethod(self,
                       originalSel,
                       originalImp,
                       method_getTypeEncoding(originalMethod))
        
        class_addMethod(self,
                       newSel,
                       newImp,
                       method_getTypeEncoding(newMethod))
        
        if let swizzledOriginal = class_getInstanceMethod(self, originalSel),
           let swizzledNew = class_getInstanceMethod(self, newSel) {
            method_exchangeImplementations(swizzledOriginal, swizzledNew)
        }
        
        return true
    }
    
    @discardableResult
    @objc class func hw_swizzleClassMethod(originalSel: Selector, with newSel: Selector) -> Bool {
        guard let classObject = object_getClass(self),
              let originalMethod = class_getInstanceMethod(classObject, originalSel),
              let newMethod = class_getInstanceMethod(classObject, newSel) else {
            return false
        }
        
        method_exchangeImplementations(originalMethod, newMethod)
        return true
    }
}
