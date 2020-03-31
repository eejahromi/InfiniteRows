//
//  InfiniteScrollView.swift
//  InfiniteRows
//
//  Created by Ehsan Jahromi on 3/29/20.
//  Copyright © 2020 Ehsan Jahromi. All rights reserved.
//

import UIKit

/*

let infiniteScrollAnimationDuration: TimeInterval = 0.35

private var infiniteScrollStateKey: UInt8 = 0
extension UIScrollView {
    var infiniteScrollState: InfiniteScrollState {
        get {
            return associatedObject(base: self, key: &infiniteScrollStateKey) { return InfiniteScrollState() }
        }
        set { associateObject(base: self, key: &infiniteScrollStateKey, value: newValue) }
    }
}

extension UIScrollView {        //Public methods
    func isAnimatingInfiniteScroll() -> Bool {
        return infiniteScrollState.loading
    }
    func addInfiniteScrollWithHandler(handler: @escaping (UIScrollView)->()) {
        infiniteScrollState.infiniteScrollHandler = handler
        
        guard !infiniteScrollState.initialized else { return }
        
        panGestureRecognizer.addTarget(self, action: #selector(UIScrollView.infiniteScrollHandlePanGesture(panGR:)))
        infiniteScrollState.initialized = true
    }
    func removeInfiniteScroll() {
        guard infiniteScrollState.initialized else { return }
        
        panGestureRecognizer.removeTarget(self, action: #selector(UIScrollView.infiniteScrollHandlePanGesture(panGR:)))
        infiniteScrollState.indicatorView?.removeFromSuperview()
        infiniteScrollState.indicatorView = nil
        infiniteScrollState.initialized = false
    }
    func finishInfiniteScroll() {
        finishInfiniteScrollWithCompletion(handler: nil)
    }
    func finishInfiniteScrollWithCompletion(handler: InfiniteScrollHandler?) {
        if infiniteScrollState.loading {
            stopAnimatingInfiniteScrollWithCompletion(handler: handler)
        }
    }
    func setInfiniteScrollIndicatorStyle(style: UIActivityIndicatorView.Style) {
        infiniteScrollState.indicatorStyle = style
        //        if infiniteScrollState.indicatorView is UIActivityIndicatorView {
        infiniteScrollState.indicatorView?.style = style
        //        }
    }
    func infiniteScrollIndicatorStyle() -> UIActivityIndicatorView.Style {
        return infiniteScrollState.indicatorStyle
    }
    func setInfiniteScrollIndicatorView(indicatorView: UIActivityIndicatorView) {
        indicatorView.isHidden = true
        infiniteScrollState.indicatorView = indicatorView
    }
    func infiniteScrollIndicatorView() -> UIActivityIndicatorView? {
        return infiniteScrollState.indicatorView
    }
    func setInfiniteScrollIndicatorMargin(margin: Double) {
        infiniteScrollState.indicatorMargin = margin
    }
    func infiniteScrollIndicatorMargin() -> Double {
        return infiniteScrollState.indicatorMargin
    }
}

extension UIScrollView {        //Private methods
//    override public class func initialize() {
//        struct Static { static var token: dispatch_once_t = 0; }
//        dispatch_once(&Static.token) {
//            let originalOffsetMethod = class_getInstanceMethod(self, Selector("setContentOffset:"));
//            let swizzledOffsetMethod = class_getInstanceMethod(self, #selector(UIScrollView.infiniteScrollSetContentOffset(_:)));
//            method_exchangeImplementations(originalOffsetMethod, swizzledOffsetMethod);
//
//            let originalSizeMethod = class_getInstanceMethod(self, Selector("setContentSize:"));
//            let swizzledSizeMethod = class_getInstanceMethod(self, #selector(UIScrollView.infiniteScrollSetContentSize(_:)));
//            method_exchangeImplementations(originalSizeMethod, swizzledSizeMethod);
//        }
//    }
    @objc private func infiniteScrollHandlePanGesture(panGR: UIPanGestureRecognizer) {
        if panGR.state == .ended {
            scrollToInfiniteIndicatorIfNeeded()
        }
    }
    @objc private func infiniteScrollSetContentOffset(contentOffset: CGPoint) {
        infiniteScrollSetContentOffset(contentOffset: contentOffset)
        
        if infiniteScrollState.initialized {
            infiniteScrollViewDidScroll(contentOffset: contentOffset)
        }
    }
    @objc private func infiniteScrollSetContentSize(contentSize: CGSize) {
        infiniteScrollSetContentSize(contentSize: contentSize)
        
        if infiniteScrollState.initialized {
            positionInfiniteScrollIndicatorWithContentSize(contentSize: contentSize)
        }
    }
    private func clampContentSizeToFitVisibleBounds(contentSize: CGSize) -> Double {
        let minHeight = Double(bounds.size.height) - Double(contentInset.top) - originalBottomInset()
        return max(Double(contentSize.height), minHeight)
    }
    private func originalBottomInset() -> Double {
        let inset = Double(contentInset.bottom) - infiniteScrollState.extraBottomInset - infiniteScrollState.indicatorInset
        return inset
    }
    private func callInfiniteScrollHandler() {
        if let handler = infiniteScrollState.infiniteScrollHandler {
            handler(self)
        }
    }
    private func getOrCreateActivityIndicatorView() -> UIActivityIndicatorView {
        var activityIndicator = infiniteScrollIndicatorView()
        if activityIndicator == nil {
            activityIndicator = UIActivityIndicatorView(style: infiniteScrollIndicatorStyle())
            setInfiniteScrollIndicatorView(indicatorView: activityIndicator!)
        }
        if activityIndicator!.superview != self {
            addSubview(activityIndicator!)
        }
        return activityIndicator!
    }
    private func infiniteIndicatorRowHeight() -> Double {
        let indicator = getOrCreateActivityIndicatorView()
        let indicatorHeight = Double(indicator.bounds.size.height)
        let height = indicatorHeight + infiniteScrollIndicatorMargin() * 2
        return height
    }
    private func positionInfiniteScrollIndicatorWithContentSize(contentSize: CGSize) {
        let indicator = getOrCreateActivityIndicatorView()
        let contentHeight = clampContentSizeToFitVisibleBounds(contentSize: contentSize)
        let indicatorRowHeight = infiniteIndicatorRowHeight()
        let center = CGPoint(x: contentSize.width * 0.5, y: CGFloat(contentHeight + indicatorRowHeight * 0.5))
        if !indicator.center.equalTo(center) {
            indicator.center = center
        }
    }
    private func startAnimatingInfiniteScroll() {
        let indicator = getOrCreateActivityIndicatorView()
        
        positionInfiniteScrollIndicatorWithContentSize(contentSize: contentSize)
        indicator.isHidden = false
        indicator.startAnimating()
        
        let indicatorInset = infiniteIndicatorRowHeight()
        var contentInset = self.contentInset
        contentInset.bottom += CGFloat(indicatorInset)
        let adjustedContentHeight = clampContentSizeToFitVisibleBounds(contentSize: contentSize)
        let extraBottomInset = adjustedContentHeight - Double(contentSize.height)
        contentInset.bottom += CGFloat(extraBottomInset)
        
        infiniteScrollState.indicatorInset = indicatorInset
        infiniteScrollState.extraBottomInset = extraBottomInset
        infiniteScrollState.loading = true
        
        setInfiniteScrollViewContentInset(contentInset: contentInset, animated: true) { (finished) in
            if finished {
                self.scrollToInfiniteIndicatorIfNeeded()
            }
        }
    }
    private func stopAnimatingInfiniteScrollWithCompletion(handler: InfiniteScrollHandler?) {
        let indicator = infiniteScrollIndicatorView()!
        
        var insets = self.contentInset
        insets.bottom -= CGFloat(infiniteScrollState.indicatorInset)
        insets.bottom -= CGFloat(infiniteScrollState.extraBottomInset)
        infiniteScrollState.indicatorInset = 0
        infiniteScrollState.extraBottomInset = 0
        
        setInfiniteScrollViewContentInset(contentInset: insets, animated: true) { (finished) in
            indicator.stopAnimating()
            indicator.isHidden = true
            self.infiniteScrollState.loading = false
            
            if finished {
                let newY = self.contentSize.height - (self.bounds.size.height) + self.contentInset.bottom
                if self.contentOffset.y > newY && newY > 0 {
                    self.setContentOffset(CGPoint(x: 0, y: newY), animated: true)
                }
            }
            handler?(self)
        }
    }
    private func infiniteScrollViewDidScroll(contentOffset: CGPoint) {
        let contentHeight = clampContentSizeToFitVisibleBounds(contentSize: contentSize)
        let actionOffset = contentHeight - Double(bounds.size.height) + originalBottomInset()
        let hasActualContent = contentSize.height > 1
        
        guard hasActualContent else { return }
        guard isDragging else { return }
        guard !infiniteScrollState.loading else { return }
        
        if contentOffset.y > CGFloat(actionOffset) {
            startAnimatingInfiniteScroll()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.callInfiniteScrollHandler()
            }
        }
    }
    private func scrollToInfiniteIndicatorIfNeeded() {
        guard !isDragging else { return }
        guard infiniteScrollState.loading else { return }
        
        let contentHeight = clampContentSizeToFitVisibleBounds(contentSize: contentSize)
        let indicatorRowHeight = infiniteIndicatorRowHeight()
        
        let minY = contentHeight - Double(bounds.size.height) + originalBottomInset()
        let maxY = minY + indicatorRowHeight
        
        if contentOffset.y > CGFloat(minY) && contentOffset.y < CGFloat(maxY) {
            setContentOffset(CGPoint(x: 0, y: maxY), animated: true)
        }
    }
    private func setInfiniteScrollViewContentInset(contentInset: UIEdgeInsets, animated: Bool, completion: ((Bool)->())?) {
        let animations = { self.contentInset = contentInset }
        if animated {
            UIView.animate(withDuration: infiniteScrollAnimationDuration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: animations, completion: completion)
        } else {
            UIView.performWithoutAnimation(animations)
            completion?(true)
        }
    }
}

extension UIScrollView {        //Support
    class InfiniteScrollState {
        var initialized = false
        var loading = false
        var indicatorView: UIActivityIndicatorView?
        var indicatorStyle = UIActivityIndicatorView.Style.gray
        var extraBottomInset = 0.0
        var indicatorInset = 0.0
        var indicatorMargin = 11.0
        var infiniteScrollHandler: InfiniteScrollHandler?
        
        init() { }
    }
    func associatedObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, initialiser: () -> ValueType) -> ValueType {
        if let associated = objc_getAssociatedObject(base, key) as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated, .OBJC_ASSOCIATION_RETAIN)
        return associated
    }
    func associateObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, value: ValueType) {
        objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
    typealias InfiniteScrollHandler = (UIScrollView)->()
}
 
*/
