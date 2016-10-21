//
//  SegueViewController.swift
//  Blocks
//
//  Created by ryan on 10/21/16.
//  Copyright © 2016 pi. All rights reserved.
//

import UIKit
import Blocks

class SegueViewController: UIViewController {

    @IBAction func showModal(_ sender: AnyObject) {
        BSegue(
            source: self,
            destination: { () -> UIViewController in
                return UIViewController.viewControllerFromStoryboard(name: "Main", identifier: "new")
            }) { () -> BSegueStyle in
                return BSegueStyle.presentModally(animated: true)
            }.perform()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
