import Foundation

/*
 example usage:
 let retVal = delay(2.0) {
   println("Later")
 }
 delay(1.0) {
   cancel_delay(retVal)
 }
 */

internal typealias dispatch_cancelable_closure = (_ cancel : Bool) -> Void

internal func delay(_ time:TimeInterval, closure:@escaping ()->Void) ->  dispatch_cancelable_closure? {
    
    func dispatch_later(_ clsr:@escaping ()->Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: clsr)
    }
    
    let closure:()->() = closure
    var cancelableClosure:dispatch_cancelable_closure?
    
    let delayedClosure:dispatch_cancelable_closure = { cancel in
        
        if (cancel == false) {
            DispatchQueue.main.async(execute: closure as @convention(block) () -> Void)
        }
        cancelableClosure = nil
    }
    
    cancelableClosure = delayedClosure
    
    dispatch_later {
        if let delayedClosure = cancelableClosure {
            delayedClosure(false)
        }
    }
    
    return cancelableClosure;
}

internal func cancel_delay(_ closure:dispatch_cancelable_closure?) {
    
    if closure != nil {
        closure!(true)
    }
}
