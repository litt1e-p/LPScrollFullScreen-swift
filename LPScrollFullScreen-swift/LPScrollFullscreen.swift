// The MIT License (MIT)
//
// Copyright (c) 2015-2016 litt1e-p ( https://github.com/litt1e-p )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import UIKit

enum LPScrollDirection
{
    case LPScrollDirectionNone
    case LPScrollDirectionUp
    case LPScrollDirectionDown
}

class LPScrollFullScreen: NSObject, UIScrollViewDelegate, UITableViewDelegate, UIWebViewDelegate
{
    weak var delegate: LPScrolldelegate?
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
        if forwardTarget!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:))) {
            forwardTarget!.scrollViewDidScroll(scrollView)
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
                    guard ((delegate?.respondsToSelector(#selector(LPScrolldelegate.scrollFullScreen(_:scrollViewDidScrollUp:)))) != nil) else {
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
                    guard ((delegate?.respondsToSelector(#selector(LPScrolldelegate.scrollFullScreen(_:scrollViewDidScrollDown:)))) != nil) else {
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
        if forwardTarget!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:))) {
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
                    guard ((delegate?.respondsToSelector(#selector(LPScrolldelegate.scrollFullScreenScrollViewDidEndDraggingScrollUp(_:)))) != nil) else {
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
                    guard ((delegate?.respondsToSelector(#selector(LPScrolldelegate.scrollFullScreenScrollViewDidEndDraggingScrollDown(_:)))) != nil) else {
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
        if ((forwardTarget?.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:)))) != nil) {
            ret = (forwardTarget?.scrollViewShouldScrollToTop!(scrollView))!
        }
        if ((delegate?.respondsToSelector(#selector(LPScrolldelegate.scrollFullScreenScrollViewDidEndDraggingScrollDown(_:)))) != nil) {
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
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        if forwardTarget!.respondsToSelector(aSelector) {
            return forwardTarget
        }
        return nil;
    }
    
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

private extension LPScrollFullScreen
{
    func detectScrollDirection(currentOffsetY: CGFloat, previousOffsetY: CGFloat) -> LPScrollDirection {
        return currentOffsetY > previousOffsetY ? .LPScrollDirectionUp : currentOffsetY < previousOffsetY ? .LPScrollDirectionDown : .LPScrollDirectionNone;
    }
}

@objc protocol LPScrolldelegate: NSObjectProtocol
{
    func scrollFullScreen(fullScreenProxy: LPScrollFullScreen, scrollViewDidScrollUp deltaY: CGFloat)
    func scrollFullScreen(fullScreenProxy: LPScrollFullScreen, scrollViewDidScrollDown deltaY: CGFloat)
    func scrollFullScreenScrollViewDidEndDraggingScrollUp(fullScreenProxy: LPScrollFullScreen)
    func scrollFullScreenScrollViewDidEndDraggingScrollDown(fullScreenProxy: LPScrollFullScreen)
}