import Foundation


public struct BConstraint {
    
    // vfs 로 안되는 부분은 NSLayoutConstraint 를 직접 사용해야함 (center 정렬이 vfs 로 안됨)
    public static func centerH(_ view: UIView, superview: UIView) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        return const
    }
    
    public static func centerV(_ view: UIView, superview: UIView) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
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

public struct BConstraintsBuilder {
    fileprivate var views: [String: AnyObject] = [:]
    fileprivate var metrics: [String: AnyObject] = [:]
    fileprivate(set) public var constraints: [NSLayoutConstraint] = []
    
    public init() {
    }
    
    public init(view: UIView, name: String) {
        view.translatesAutoresizingMaskIntoConstraints = false
        views[name] = view
    }
    
    public func addView(_ view: AnyObject, name: String) -> BConstraintsBuilder {
        if let view = view as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        var const = self
        const.views[name] = view
        return const
    }
    
    // translatesAutoresizingMaskIntoConstraints 변경없이 VFS에서 viewname 만 필요한 경우가 있음
    public func addOnlyViewName(_ view: AnyObject, name: String) -> BConstraintsBuilder {
        var const = self
        const.views[name] = view
        return const
    }
    
    public func addMetricValue(_ value: AnyObject, name: String) -> BConstraintsBuilder {
        var const = self
        const.metrics[name] = value
        return const
    }
    
    public func addVFS(_ vfs: String, options: NSLayoutFormatOptions) -> BConstraintsBuilder {
        var const = self
        let c = NSLayoutConstraint.constraints(withVisualFormat: vfs, options: options, metrics: metrics, views: views)
        const.constraints = const.constraints + c
        return const
    }
    
    public func addVFS(_ vfsArray: String...) -> BConstraintsBuilder {
        var const = self
        for vfs in vfsArray {
            const = const.addVFS(vfs, options: NSLayoutFormatOptions(rawValue: 0))
        }
        return const
    }
}
