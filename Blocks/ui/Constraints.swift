import Foundation


public struct Constraint {
    
    // vfs 로 안되는 부분은 NSLayoutConstraint 를 직접 사용해야함 (center 정렬이 vfs 로 안됨)
    public static func centerH(_ view: UIView, superview: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: constant)
        return const
    }
    
    public static func centerV(_ view: UIView, superview: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: constant)
        return const
    }

    public static func width(_ view: UIView, width: CGFloat) -> NSLayoutConstraint {
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: width)
        return const
    }
    
    public static func height(_ view: UIView, height: CGFloat) -> NSLayoutConstraint {
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: height)
        return const
    }
}

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

