# LPScrollFullScreen-swift

swift rewrite version for scrollFullScreen simply to use with 2 line codes only

# Additional

Objective C version is [here](https://github.com/litt1e-p/LPScrollFullScreen)

# Installation

```swift
pod 'LPScrollFullScreen-swift', '~> 1.0.0'
```

```swift
var scrollProxy: LPScrollFullScreen?
/**  in tableView */
scrollProxy = LPScrollFullScreen(forwardTarget: self)
self.tableView.delegate = scrollProxy!
/**  in webView */
scrollProxy = LPScrollFullScreen(forwardTarget: self)
webView?.scrollView.delegate = scrollProxy
```
# Screenshot

<img src="screenshot.gif" width=320>

# Release Notes

- 1.0.0

`first release version`

# License

MIT


