import Foundation

public struct ConstraintsBuilder {
    fileprivate var viewBuffer: [String:(AnyObject,Bool?)] = [:]    // name:(view,autoresizingMask)
    fileprivate var metrics: [String:AnyObject] = [:]
    fileprivate var vfsAndOptions: [(String, NSLayoutFormatOptions)] = []
    
    var viewDictionary: [String:AnyObject] {
        var nameAndView: [String:AnyObject] = [:]
        viewBuffer.forEach { (name, viewAndMask) in
            nameAndView[name] = viewAndMask.0
        }
        return nameAndView
    }
    
    public init() {
    }
    public func set(view: AnyObject, name: String) -> ConstraintsBuilder {
        return set(view: view, name: name, autoresizingMask: false)
    }
    public func set(view: AnyObject, name: String, autoresizingMask: Bool?) -> ConstraintsBuilder {
        var builder = self
        builder.viewBuffer[name] = (view,autoresizingMask)
        return builder
    }
    public func set(metric value: AnyObject, name: String) -> ConstraintsBuilder {
        var builder = self
        builder.metrics[name] = value
        return builder
    }
    public func set(vfs: String..., options: NSLayoutFormatOptions = NSLayoutFormatOptions(rawValue: 0)) -> ConstraintsBuilder {
        var builder = self
        vfs.forEach { (str) in
            builder.vfsAndOptions += [(str, options)]
        }
        return builder
    }
}

extension Array where Element: NSLayoutConstraint {
    public init(_ builder: ConstraintsBuilder) {
        
        // view autoresizingMask 적용
        builder.viewBuffer.forEach { (name,viewAndMask) in
            if let view = viewAndMask.0 as? UIView, let autoresizingMask = viewAndMask.1 {
                view.translatesAutoresizingMaskIntoConstraints = autoresizingMask
            }
        }
        
        var constraints: [NSLayoutConstraint] = []
        builder.vfsAndOptions.forEach { (vfs,options) in
            constraints += NSLayoutConstraint.constraints(withVisualFormat: vfs, options: options, metrics: builder.metrics, views: builder.viewDictionary)
        }
        self.init(constraints as! [Element])
    }
}

extension NSLayoutConstraint {
    public convenience init(view: UIView, centerHOf superview: UIView, constant: CGFloat = 0) {
        self.init(item: view, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: constant)
    }
    public convenience init(view: UIView, centerVOf superview: UIView, constant: CGFloat = 0) {
        self.init(item: view, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: constant)
    }
}
