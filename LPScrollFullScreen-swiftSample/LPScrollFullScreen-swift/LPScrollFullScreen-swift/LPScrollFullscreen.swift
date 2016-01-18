//
//  LPScrollFullscreen.swift
//  LPScrollFullScreen-swift
//
//  Created by litt1e-p on 16/1/15.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import Foundation
import UIKit

enum LPScrollDirection {
    case LPScrollDirectionNone
    case LPScrollDirectionUp
    case LPScrollDirectionDown
}

class LPScrollFullScreen: NSObject, UIScrollViewDelegate, UITableViewDelegate, UIWebViewDelegate {
    
    weak var delegate: LPScrollFullscreenDelegate?
    var upThresholdY: CGFloat // up distance until fire. default 0 px.
    var downThresholdY: CGFloat // down distance until fire. default 200 px
    
    private var previousScrollDirection: LPScrollDirection = .LPScrollDirectionNone
    private var previousOffsetY: CGFloat = 0.0
    private var accumulatedY: CGFloat = 0.0
    private weak var forwardTarget: AnyObject?
    private var navigationBarOriginalBottom: CGFloat
    
    init(forwardTarget: AnyObject) {
        downThresholdY              = 200.0
        upThresholdY                = 0.0
        self.forwardTarget          = forwardTarget
        let forwardTargetVc         = forwardTarget as! UIViewController
        navigationBarOriginalBottom = CGRectGetMaxY((forwardTargetVc.navigationController?.navigationBar.frame)!)
        super.init()
        self.reset()
    }
    
    func reset() {
        previousOffsetY = 0.0;
        accumulatedY = 0.0;
        previousScrollDirection = .LPScrollDirectionNone;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if forwardTarget!.respondsToSelector("scrollViewDidScroll:") {
            forwardTarget!.scrollViewDidScroll!(scrollView)
        }
        let currentOffsetY = scrollView.contentOffset.y
        let currentScrollDirection = detectScrollDirection(currentOffsetY, previousOffsetY: previousOffsetY)
        let topBoundary = -scrollView.contentInset.top
        let bottomBoundary = scrollView.contentSize.height + scrollView.contentInset.bottom
        let isOverTopBoundary = currentOffsetY <= topBoundary
        let isOverBottomBoundary = currentOffsetY >= bottomBoundary
        let isBouncing = (isOverTopBoundary && currentScrollDirection != .LPScrollDirectionDown) || (isOverBottomBoundary && currentScrollDirection != .LPScrollDirectionUp)
        if isBouncing || !scrollView.dragging {
            return
        }
        
        let deltaY = previousOffsetY - currentOffsetY
        accumulatedY += deltaY
        
        switch currentScrollDirection {
            case .LPScrollDirectionUp:
                let isOverThreshold = accumulatedY < -upThresholdY
                if isOverThreshold || isOverBottomBoundary {
                    guard ((delegate?.respondsToSelector("scrollFullScreen:scrollViewDidScrollUp:")) != nil) else {
                        let forwardTargetVc = forwardTarget as! UIViewController
                        forwardTargetVc.moveNavigationBar(deltaY, animated: true)
                        forwardTargetVc.moveTabBar(-deltaY, animated: true)
                        forwardTargetVc.moveToolbar(-deltaY, animated: true)
                        break
                    }
                    delegate?.scrollFullScreen(self, scrollViewDidScrollUp: deltaY)
                }
            case .LPScrollDirectionDown:
                let isOverThreshold = accumulatedY > downThresholdY
                if isOverThreshold || isOverTopBoundary {
                    guard ((delegate?.respondsToSelector("scrollFullScreen:scrollViewDidScrollDown:")) != nil) else {
                        let forwardTargetVc = forwardTarget as! UIViewController
                        forwardTargetVc.moveNavigationBar(deltaY, animated: true)
                        forwardTargetVc.moveTabBar(-deltaY, animated: true)
                        forwardTargetVc.moveToolbar(-deltaY, animated: true)
                        break
                    }
                    delegate?.scrollFullScreen(self, scrollViewDidScrollDown: deltaY)
                }
                
            case .LPScrollDirectionNone:
                break
        }
        if !isOverTopBoundary && !isOverBottomBoundary && previousScrollDirection != currentScrollDirection {
            accumulatedY = 0
        }
        previousScrollDirection = currentScrollDirection
        previousOffsetY = currentOffsetY
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if forwardTarget!.respondsToSelector("scrollViewDidEndDragging:willDecelerate:") {
            forwardTarget!.scrollViewDidEndDragging!(scrollView, willDecelerate: decelerate)
        }
        let currentOffsetY = scrollView.contentOffset.y
        let topBoundary = -scrollView.contentInset.top
        let bottomBoundary = scrollView.contentSize.height + scrollView.contentInset.bottom
        switch previousScrollDirection {
            case .LPScrollDirectionUp:
                let isOverThreshold = accumulatedY < -upThresholdY
                let isOverBottomBoundary = currentOffsetY >= bottomBoundary
                if isOverThreshold || isOverBottomBoundary {
                    guard ((delegate?.respondsToSelector("scrollFullScreenScrollViewDidEndDraggingScrollUp:")) != nil) else {
                        let forwardTargetVc = forwardTarget as! UIViewController
                        forwardTargetVc.hideNavigationBar(true)
                        forwardTargetVc.hideTabBar(true)
                        forwardTargetVc.hideToolbar(true)
                        break
                    }
                    delegate?.scrollFullScreenScrollViewDidEndDraggingScrollUp(self)
                }
            case .LPScrollDirectionDown:
                let isOverThreshold = accumulatedY > downThresholdY
                let isOverTopBoundary = currentOffsetY <= topBoundary
                if isOverThreshold || isOverTopBoundary {
                    guard ((delegate?.respondsToSelector("scrollFullScreenScrollViewDidEndDraggingScrollDown:")) != nil) else {
                        let forwardTargetVc = forwardTarget as! UIViewController
                        forwardTargetVc.showNavigationBar(true)
                        forwardTargetVc.showTabBar(true)
                        forwardTargetVc.showToolbar(true)
                        break
                    }
                    delegate?.scrollFullScreenScrollViewDidEndDraggingScrollDown(self)
                }
            case .LPScrollDirectionNone:
                break
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y == -navigationBarOriginalBottom {
            let forwardTargetVc = forwardTarget as! UIViewController
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                forwardTargetVc.showNavigationBar(true)
                forwardTargetVc.showTabBar(true)
                forwardTargetVc.showToolbar(true)
            })
        }
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        var ret = true
        if ((forwardTarget?.respondsToSelector("scrollViewShouldScrollToTop:")) != nil) {
            ret = (forwardTarget?.scrollViewShouldScrollToTop!(scrollView))!
        }
        if ((delegate?.respondsToSelector("scrollFullScreenScrollViewDidEndDraggingScrollDown:")) != nil) {
            delegate!.scrollFullScreenScrollViewDidEndDraggingScrollDown(self)
        } else {
            let forwardTargetVc = forwardTarget as! UIViewController
            forwardTargetVc.showNavigationBar(true)
            forwardTargetVc.showTabBar(true)
            forwardTargetVc.showToolbar(true)
        }
        return ret
    }
    
    // MARK: - swift does not support NSMethodSignature
//    func methodSignatureForSelector(selector: SEL) -> NSMethodSignature {
//        
//    }
    
    // MARK: - swift does not support NSInvocation
//    func forwardInvocation(anInvocation: NSInvocation!) {
//
//    }
    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        var ret = super.respondsToSelector(aSelector)
        if !ret {
            ret = forwardTarget!.respondsToSelector(aSelector)
        }
        return ret
    }
    
    override func conformsToProtocol(aProtocol: Protocol) -> Bool {
        var ret = super.conformsToProtocol(aProtocol)
        if !ret {
            ret = forwardTarget!.conformsToProtocol(aProtocol)
        }
        return ret
    }
}

private extension LPScrollFullScreen {
    
    func detectScrollDirection(currentOffsetY: CGFloat, previousOffsetY: CGFloat) -> LPScrollDirection {
        return currentOffsetY > previousOffsetY ? .LPScrollDirectionUp : currentOffsetY < previousOffsetY ? .LPScrollDirectionDown : .LPScrollDirectionNone;
    }
}

protocol LPScrollFullscreenDelegate: NSObjectProtocol {
    
    func scrollFullScreen(fullScreenProxy: LPScrollFullScreen, scrollViewDidScrollUp deltaY: CGFloat)
    func scrollFullScreen(fullScreenProxy: LPScrollFullScreen, scrollViewDidScrollDown deltaY: CGFloat)
    func scrollFullScreenScrollViewDidEndDraggingScrollUp(fullScreenProxy: LPScrollFullScreen)
    func scrollFullScreenScrollViewDidEndDraggingScrollDown(fullScreenProxy: LPScrollFullScreen)
}