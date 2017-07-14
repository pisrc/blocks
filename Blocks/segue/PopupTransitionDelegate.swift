import Foundation


final class PopupTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, OriginHandlerHavableTransitionDelegate,  SizeHandlerHavableTransitionDelgate, DimmedColorHavableTransitionDelegate {
    
    // presentationview 의 size 를 정의 합니다.
    var sizeHandler: SizeHandlerFunc?
    var originHandler: OriginHandlerFunc?
    var dimmedColor: UIColor?
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopupPresentationController(presentedViewController: presented, presenting: presenting, dimmedColor: dimmedColor)
        presentationController.sizeHandler = sizeHandler
        presentationController.originHandler = originHandler
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = PopupAnimatedTransitioning()
        animationController.isPresentation = true
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = PopupAnimatedTransitioning()
        animationController.isPresentation = false
        return animationController
    }
}

final class PopupPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    var chromeView: UIView = UIView()   // 배경을 반투명하게 가리는 검정 배경
    var sizeHandler: SizeHandlerFunc?
    var originHandler: OriginHandlerFunc?
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, dimmedColor: UIColor?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        chromeView.backgroundColor = dimmedColor ?? UIColor(white: 0.0, alpha: 0.4)
        chromeView.alpha = 0.0
        chromeView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(PopupPresentationController.chromeViewTapped(_:))))
        
        NotificationCenter.default.addObserver(self, selector: #selector(PopupPresentationController.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardNotification(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            // 키보드가 노출 여부가 화면사이즈에 영향을 미치게 합니다.
            containerView?.frame.size.height = keyboardEndFrame.origin.y
        }
    }
    
    func chromeViewTapped(_ gesture: UIGestureRecognizer) {
        if(gesture.state == UIGestureRecognizerState.ended) {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        // 기본적으로는 화면의 80% 할당, sizeHandler 지정되면 handler 에서 지정한 size 로 설정
        if let sizeHandler = sizeHandler {
            return sizeHandler(CGRect(origin: CGPoint.zero, size: parentSize))
        }
        let width = parentSize.width * 0.8
        let height = parentSize.height * 0.8
        return CGSize(width: width, height: height)
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        var presentedViewFrame = CGRect.zero
        if let containerBounds = containerView?.bounds {
            presentedViewFrame.size = size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerBounds.size)
            presentedViewFrame.origin = {
                if let originHandler = originHandler {
                    return originHandler(containerBounds)
                } else {
                    // 화면 중앙에 위치
                    return CGPoint(
                        x: (containerBounds.width - presentedViewFrame.size.width) / 2,
                        y: (containerBounds.height - presentedViewFrame.size.height) / 2)
                }
            }()
        }
        return presentedViewFrame
    }
    
    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView {
            chromeView.frame = containerView.bounds
            chromeView.alpha = 0.0
            containerView.insertSubview(chromeView, at: 0)
            if let coordinator = presentedViewController.transitionCoordinator {
                coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.chromeView.alpha = 1.0
                    }, completion: nil)
            } else {
                self.chromeView.alpha = 1.0
            }
        }
        
        if let presented = presentedView {
            presented.alpha = 0.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.chromeView.alpha = 0.0
                }, completion: nil)
        } else {
            self.chromeView.alpha = 0.0
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        if let bounds = containerView?.bounds {
            chromeView.frame = bounds
        }
        presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override var shouldPresentInFullscreen : Bool {
        return true
    }
    
    override var adaptivePresentationStyle : UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
}


final class PopupAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresentation = false
    var positionDelegate: AnimatedTransitioningPositionDelegate?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let screens: (from:UIViewController, to:UIViewController) = (
            transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!,
            transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        
        let tedVC = self.isPresentation ? screens.to : screens.from
        //let tingVC = self.isPresentation ? screens.from : screens.to
        
        containerView.addSubview(tedVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 300.0,
            initialSpringVelocity: 5.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: { () -> Void in
                if self.isPresentation {
                    tedVC.view.alpha = 1.0
                } else {
                    tedVC.view.alpha = 0.0
                }
            },
            completion: { (value: Bool) -> Void in
                if !self.isPresentation {
                    tedVC.view.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
        })
    }
}
