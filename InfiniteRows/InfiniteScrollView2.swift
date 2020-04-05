//
//  InfiniteScrollView.swift
//  InfiniteRows
//
//  Created by Ehsan Jahromi on 3/28/20.
//  Copyright © 2020 Ehsan Jahromi. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

private var UIScrollViewInfiniteScrollView: Void?

extension UIScrollView {
    var infiniteScrollView: InfiniteScrollView? {
        get {
            return objc_getAssociatedObject(self, &UIScrollViewInfiniteScrollView) as? InfiniteScrollView
        }
        set {
            willChangeValue(forKey: ObserverConstants.uiScrollViewInfiniteScrollView.rawValue)
            objc_setAssociatedObject(self, &UIScrollViewInfiniteScrollView, newValue, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: ObserverConstants.uiScrollViewInfiniteScrollView.rawValue)
        }
    }

    func addInfiniteScrollingWithActionHandler(handler: @escaping () -> Void) {
        if infiniteScrollView == nil {
            let view = InfiniteScrollView(frame: CGRect(x: 0,
                                                        y: contentSize.height,
                                                        width: bounds.size.width,
                                                        height: 60))
            view.infiniteScrollingHandler = handler
            view.scrollView = self
            addSubview(view)
            view.originalBottomInset = contentInset.bottom
            infiniteScrollView = view
            showsInfiniteScrolling = true
        }
    }

    func triggerInfiniteScrolling() {
        DispatchQueue.main.async {
            self.infiniteScrollView?.updateState(updatedValue: .triggered)
            self.infiniteScrollView?.startAnimating()
        }
    }

    var showsInfiniteScrolling: Bool {
        get {
            return infiniteScrollView?.isHidden == false
        }
        set {
            guard let scrollView = infiniteScrollView else {
                return
            }
            infiniteScrollView?.isHidden = !showsInfiniteScrolling
            if showsInfiniteScrolling == false {
                if scrollView.isObserving == true {
                    removeObserver(scrollView, forKeyPath: ObserverConstants.contentOffset.rawValue)
                    removeObserver(scrollView, forKeyPath: ObserverConstants.contentSize.rawValue)
                    scrollView.resetScrollViewContentInset()
                    scrollView.isObserving = false
                }
            }
            else {
                if scrollView.isObserving == false {
                    addObserver(scrollView, forKeyPath: ObserverConstants.contentOffset.rawValue, options: .new, context: nil)
                    addObserver(scrollView, forKeyPath: ObserverConstants.contentSize.rawValue, options: .new, context: nil)
                    scrollView.scrollViewContentInsetForInfiniteScrolling()
                    scrollView.isObserving = true

                    scrollView.setNeedsLayout()
                    scrollView.frame = CGRect(x: 0.0, y: contentSize.height, width: scrollView.bounds.size.width, height: 60.0)
                }
            }
        }
    }
}

enum InfiniteScrollState {
    case stopped
    case triggered
    case loading
    case all
}

enum ObserverConstants: String {
    case contentSize
    case contentOffset
    case uiScrollViewInfiniteScrollView
}

class InfiniteScrollView: UIView {
    var enabled = true
    var isObserving = false
    weak var scrollView: UIScrollView?
    var originalBottomInset: CGFloat = 0.0
    var infiniteScrollingHandler: (() -> Void)?

    lazy private var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .gray)
        indicatorView.hidesWhenStopped = true
        addSubview(indicatorView)
        return indicatorView
    }()

    private var state: InfiniteScrollState = .stopped

    // MARK: - Inits

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleWidth
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public functions

    func triggerRefresh() {
        DispatchQueue.main.async {
            self.updateState(updatedValue: .triggered)
            self.updateState(updatedValue: .loading)
        }
    }

    func startAnimating() {
        DispatchQueue.main.async {
            self.updateState(updatedValue: .loading)
        }
    }

    func stopAnimating() {
        DispatchQueue.main.async {
            self.updateState(updatedValue: .stopped)
        }
    }

    // MARK: - View functions

    override func willMove(toSuperview newSuperview: UIView?) {
        if superview != nil && newSuperview == nil {
            if let scrollView = superview as? UIScrollView {
                if scrollView.showsInfiniteScrolling {
                    if isObserving {
                        scrollView.removeObserver(self, forKeyPath: ObserverConstants.contentOffset.rawValue)
                        scrollView.removeObserver(self, forKeyPath: ObserverConstants.contentSize.rawValue)
                        isObserving = false
                    }
                }
            }
        }
    }

    override func layoutSubviews() {
        activityIndicatorView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
    }

    // MARK: - ScrollView Insets

    func resetScrollViewContentInset() {
        var currentInsets = scrollView?.contentInset
        currentInsets?.bottom = originalBottomInset
        scrollViewContentInset(contentInset: currentInsets ?? .zero)
    }

    func scrollViewContentInsetForInfiniteScrolling() {
        var currentInsets = scrollView?.contentInset
        currentInsets?.bottom = originalBottomInset + 60
        scrollViewContentInset(contentInset: currentInsets ?? .zero)
    }

    func scrollViewContentInset(contentInset: UIEdgeInsets) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: {
                        self.scrollView?.contentInset = contentInset
        })
    }

    // MARK: - Observers

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let contentOffset: CGPoint = change?[.newKey] as? CGPoint else {
            return
        }
        if keyPath == ObserverConstants.contentOffset.rawValue && enabled == true {
            scrollViewDidScroll(contentOffset: contentOffset)
        }
        else if keyPath == ObserverConstants.contentSize.rawValue {
            layoutSubviews()
            frame = CGRect(x: 0.0, y: scrollView?.contentSize.height ?? 0.0, width: bounds.size.width, height: 60.0)
        }
        
    }

    func scrollViewDidScroll(contentOffset: CGPoint) {
        guard let scrollView = scrollView else {
            return
        }
        if state != .loading && enabled == true {
            let contentHeight = scrollView.contentSize.height
            let offsetThreshold = contentHeight - scrollView.bounds.size.height

            if scrollView.isDragging && state == .triggered {
                DispatchQueue.main.async {
                    self.updateState(updatedValue: .loading)
                }
            }
            else if contentOffset.y > offsetThreshold && contentOffset.y > 0 && state == .stopped && scrollView.isDragging {
                DispatchQueue.main.async {
                    self.updateState(updatedValue: .triggered)
                }
            }
            else if contentOffset.y < offsetThreshold && state != .stopped {
                DispatchQueue.main.async {
                    self.updateState(updatedValue: .stopped)
                }
            }
        }
    }

    // MARK: - Helpers

    func updateState(updatedValue: InfiniteScrollState) {
        if updatedValue == state {
            return
        }
        let previousState = state
        state = updatedValue
        let viewBounds = activityIndicatorView.bounds
        let origin = CGPoint(x: round((bounds.size.width - viewBounds.size.width)/2),
                             y: round((bounds.size.height - viewBounds.size.height)/2))
        let yCoordinate = scrollView?.contentSize.height ?? 0.0
        activityIndicatorView.frame = CGRect(x: origin.x, y: yCoordinate, width: viewBounds.size.width, height: viewBounds.size.height)
        switch updatedValue {
        case .stopped:
            self.activityIndicatorView.stopAnimating()
        case .loading:
            self.activityIndicatorView.startAnimating()
        default:
            break
        }

        if previousState == .triggered && updatedValue == .loading && infiniteScrollingHandler != nil && enabled {
            infiniteScrollingHandler?()
        }
    }

}
