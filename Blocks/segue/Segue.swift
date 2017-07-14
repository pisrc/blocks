import UIKit

public typealias SizeHandlerFunc = (_ parentRect: CGRect) -> CGSize
public typealias OriginHandlerFunc = (_ parentRect: CGRect) -> CGPoint

public enum SegueStyle {
    case show(animated: Bool)           // Push
    case showDetail(animated: Bool)     // 화면 전환
    case presentModally(animated: Bool) // Modal
    case presentModallyWithDirection(SegueDirection, sizeHandler: SizeHandlerFunc)
    case presentPopup(sizeHandler: SizeHandlerFunc, originHandler: OriginHandlerFunc, dimmedColor: UIColor?)
    case presentAsPopover
    case embed
}

public enum SegueDirection {
    case leftToRight
    case rightToLeft
}

protocol AnimatedSettable {
    var animated: Bool { get set }
}

protocol PresentationControllerPositionDelegate {
    func positionForPresentedView(_ containerRect: CGRect, presentedRect: CGRect) -> CGPoint
}

protocol SizeHandlerHavableTransitionDelgate {
    var sizeHandler: SizeHandlerFunc? { get set }
}

protocol OriginHandlerHavableTransitionDelegate {
    var originHandler: OriginHandlerFunc? { get set }
}

protocol DimmedColorHavableTransitionDelegate {
    var dimmedColor: UIColor? { get set }
}

protocol AnimatedTransitioningPositionDelegate {
    // animation 시작 되기 전의 초기 위치를 결정해주세요. 해당 위치부터 presentation에 명시한 위치까지 애니메이션 됩니다.
    func initialUpperViewPosition(_ finalFrameForUpper: CGRect) -> CGPoint
}


public struct Segue {
    
    public typealias Destination = () -> UIViewController
    public typealias Style = () -> SegueStyle
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
        case .presentPopup(_, _, _):
            transitionDelegate = PopupTransitionDelegate()
        case .presentAsPopover:
            transitionDelegate = nil
        case .embed:
            transitionDelegate = nil
        }
    }
    
    fileprivate func getSegue(_ destination: UIViewController, style: SegueStyle) -> UIStoryboardSegue? {
        
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
            if var transitioningDelegate = self.transitionDelegate as? SizeHandlerHavableTransitionDelgate {
                transitioningDelegate.sizeHandler = sizeHandler
            }
            
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            
        case .presentPopup(let sizeHandler, let originHandler, let dimmedColor):    // popup 창 류
            destination.modalPresentationStyle = .custom
            destination.transitioningDelegate = transitionDelegate
            if var transitioningDelegate = transitionDelegate as? SizeHandlerHavableTransitionDelgate {
                transitioningDelegate.sizeHandler = sizeHandler
            }
            if var transitioningDelegate = transitionDelegate as? OriginHandlerHavableTransitionDelegate {
                transitioningDelegate.originHandler = originHandler
            }
            if var transitioningDelegate = transitionDelegate as? DimmedColorHavableTransitionDelegate {
                transitioningDelegate.dimmedColor = dimmedColor
            }
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            
        case .presentAsPopover:
            segue = PresentAsPopoverSegue(identifier: nil, source: source, destination: destination)
            
        case .embed:
            segue = EmbedSegue(identifier: nil, source: source, destination: destination)
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

public protocol Embedable: class {
    weak var embedee: UIViewController? { get set }
}

final class EmbedSegue: UIStoryboardSegue {
    
    override func perform() {
        
        guard let embedableSource = source as? Embedable else {
            fatalError("\(type(of: source)) is not Embedable.")
        }
        
        // 기존에 존재하는 child 는 삭제
        if let embedee = embedableSource.embedee {
            embedee.willMove(toParentViewController: nil)
            embedee.view.removeFromSuperview()
            embedee.removeFromParentViewController()
            embedee.didMove(toParentViewController: nil)
        }
        
        destination.willMove(toParentViewController: source)
        source.view.addSubview(destination.view)
        source.addChildViewController(destination)
        destination.didMove(toParentViewController: source)
        let fillConsts = [NSLayoutConstraint](
            ConstraintsBuilder()
                .set(view: destination.view, name: "destview")
                .set(vfs: "V:|[destview]|", "H:|[destview]|"))
        source.view.addConstraints(fillConsts)
        embedableSource.embedee = destination
    }
}

