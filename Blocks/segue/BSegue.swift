import UIKit

public typealias SizeHandlerFunc = (_ parentSize: CGSize) -> CGSize

public enum BSegueStyle {
    case show(animated: Bool)           // Push
    case showDetail(animated: Bool)     // 화면 전환
    case presentModally(animated: Bool) // Modal
    case presentModallyWithDirection(BSegueDirection, sizeHandler: SizeHandlerFunc)
    case presentPopup(sizeHandler: SizeHandlerFunc)
    case presentAsPopover
    case embed(containerView: UIView?)
}

public enum BSegueDirection {
    case leftToRight
    case rightToLeft
}

protocol AnimatedSettable {
    var animated: Bool { get set }
}

protocol PresentationControllerPositionDelegate {
    func positionForPresentedView(_ containerRect: CGRect, presentedRect: CGRect) -> CGPoint
}

protocol SizeHandlerHasableTransitionDelgate {
    var sizeHandler: ((_ parentSize: CGSize) -> CGSize)? { get set }
}

protocol AnimatedTransitioningPositionDelegate {
    // animation 시작 되기 전의 초기 위치를 결정해주세요. 해당 위치부터 presentation에 명시한 위치까지 애니메이션 됩니다.
    func initialUpperViewPosition(_ finalFrameForUpper: CGRect) -> CGPoint
}


public struct BSegue {
    
    public typealias Destination = () -> UIViewController
    public typealias Style = () -> BSegueStyle
    public let source: UIViewController
    fileprivate let destination: Destination
    fileprivate let style: Style
    
    fileprivate var transitionDelegate: UIViewControllerTransitioningDelegate?
    
    public init(source: UIViewController, destination: @escaping Destination, style: @escaping Style) {
        self.source = source
        self.destination = destination
        self.style = style
        
        // self.segue 를 만들어야 합니다.
        switch style() {
        case .show(_):
            transitionDelegate = nil
        case .showDetail(_):
            transitionDelegate = nil
        case .presentModally(_):
            transitionDelegate = nil
        case .presentModallyWithDirection(let direction, _) :
            switch direction {
            case .leftToRight:
                transitionDelegate = LeftToRightSlideOverTransitionDelegate()
            case .rightToLeft:
                transitionDelegate = RightToLeftSlideOverTransitionDelegate()
            }
        case .presentPopup(_):
            transitionDelegate = nil
        case .presentAsPopover:
            transitionDelegate = nil
        case .embed(_):
            transitionDelegate = nil
        }
    }
    
    fileprivate func getSegue(_ destination: UIViewController, style: BSegueStyle) -> UIStoryboardSegue? {
        
        var segue: UIStoryboardSegue?
        
        switch style {
        case .show(let animated):
            
            segue = ShowSegue(identifier: nil, source: source, destination: destination)
            if var segue = segue as? AnimatedSettable {
                segue.animated = animated
            }
            
        case .showDetail(let animated):
            
            segue = ShowDetailSegue(identifier: nil, source: source, destination: destination)
            if var segue = segue as? AnimatedSettable {
                segue.animated = animated
            }
            
        case .presentModally(let animated):
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            if var segue = segue as? AnimatedSettable {
                segue.animated = animated
            }
            
        case .presentModallyWithDirection(_, let sizeHandler) :
            destination.modalPresentationStyle = .custom
            destination.transitioningDelegate = transitionDelegate
            if var transitioningDelegate = self.transitionDelegate as? SizeHandlerHasableTransitionDelgate {
                transitioningDelegate.sizeHandler = sizeHandler
            }
            
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            
        case .presentPopup(let sizeHandler):    // popup 창 류
            destination.modalPresentationStyle = .custom
            destination.transitioningDelegate = transitionDelegate
            if var transitioningDelegate = transitionDelegate as? SizeHandlerHasableTransitionDelgate {
                transitioningDelegate.sizeHandler = sizeHandler
            }
            
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            
        case .presentAsPopover:
            segue = PresentAsPopoverSegue(identifier: nil, source: source, destination: destination)
            
        case .embed(let containerView):
            segue = EmbedSegue(identifier: nil, source: source, destination: destination, container: containerView)
        }
        return segue
    }
    
    public func perform() {
        performWithTarget(nil, sender: nil)
    }
    public func performWithSender(_ sender: AnyObject?) {
        performWithTarget(nil, sender: sender)
    }
    public func performWithTarget(_ target: UIViewController?, sender: AnyObject? = nil) {
        let destination = self.destination()
        let style = self.style()
        if let segue = getSegue(destination, style: style) {
            // prepareForSegue 호출 (sender 가 있으면 sender 로 없으면 source 로)
            if let target = target {
                target.prepare(for: segue, sender: sender)
            } else {
                source.prepare(for: segue, sender: sender)
            }
            segue.perform()
        }
    }
}

final class ShowSegue: UIStoryboardSegue, AnimatedSettable {
    var animated: Bool = true
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        
    }
    
    override func perform() {
        if let navi = source.navigationController {
            navi.pushViewController(destination, animated: animated)
            // hack for swife back (when backbutton changed), back 버튼이 들어가면 swife 뒤로가기가 안되는 문제가 있어서 그것 해결
            // TODO: - xcode7 다시 확인해야함 - navi.interactivePopGestureRecognizer.delegate = navi as? UIGestureRecognizerDelegate
        }
    }
}

final class ShowDetailSegue: UIStoryboardSegue, AnimatedSettable {
    var animated: Bool = true
    override func perform() {
        if let navi = source.navigationController {
            let cnt = navi.viewControllers.count
            var controllers = Array(navi.viewControllers[0..<(cnt-1)])
            controllers.append(destination)
            navi.setViewControllers(controllers, animated: animated)
        }
    }
}

final class PresentModallySegue: UIStoryboardSegue, AnimatedSettable {
    var animated: Bool = true
    override func perform() {
        source.present(destination, animated: animated, completion: nil)
    }
}

final class PresentAsPopoverSegue: UIStoryboardSegue, UIPopoverPresentationControllerDelegate {
    override func perform() {
        destination.modalPresentationStyle = UIModalPresentationStyle.popover
        destination.preferredContentSize = CGSize(width: 100, height: 100)
        if let popoverVC = destination.popoverPresentationController {
            popoverVC.permittedArrowDirections = UIPopoverArrowDirection()
            popoverVC.delegate = self
            popoverVC.sourceView = source.view
            popoverVC.sourceRect = CGRect(x: 100.0, y: 100.0, width: 1, height: 1)
        }
        source.present(destination, animated: true, completion: nil)
    }
    
    // popoverVC.delegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

final class EmbedSegue: UIStoryboardSegue {
    
    fileprivate weak var containerView: UIView?
    
    init(identifier: String?, source: UIViewController, destination: UIViewController, container: UIView?) {
        super.init(identifier: identifier, source: source, destination: destination)
        containerView = container
    }
    
    override func perform() {
        
        // 기존에 존재하는 child 는 삭제
        containerView?.subviews.forEach({ (v) -> () in
            v.removeFromSuperview()
        })
        source.childViewControllers.forEach { (vc) -> () in
            vc.removeFromParentViewController()
        }
        
        source.addChildViewController(destination)
        containerView?.addSubview(destination.view)
        destination.didMove(toParentViewController: source)
        
        // fill
        let fillConsts = BConstraintsBuilder()
            .add(view: destination.view, name: "parentview")
            .add(vfs: "V:|[parentview]|")
            .add(vfs: "H:|[parentview]|")
            .constraints
        containerView?.addConstraints(fillConsts)
    }
}

