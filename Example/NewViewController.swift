//
//  NewViewController.swift
//  Blocks
//
//  Created by ryan on 18/07/2017.
//  Copyright © 2017 pi. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("modalPresentationStyle: \(modalPresentationStyle)")
        modalPresentationStyle = UIModalPresentationStyle.custom
        
        
    }

    deinit {
        print("[deinit] NewViewController")
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let frame = presentationController?.frameOfPresentedViewInContainerView {
            view.frame = frame
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let frame = presentationController?.frameOfPresentedViewInContainerView {
            view.frame = frame
        }
    }
}
