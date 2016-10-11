//
//  ConstraintViewController.swift
//  Blocks
//
//  Created by ryan on 10/12/16.
//  Copyright © 2016 pi. All rights reserved.
//

import UIKit
import Blocks

class ConstraintViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var centerLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let consts = BConstraintsBuilder(view: topLabel, name: "top")
            .add(view: centerLabel, name: "center")
            .add(view: bottomLabel, name: "bottom")
            .add(view: topLayoutGuide, name: "tguide")
            .add(vfs:
                "V:|[tguide][top(100)][center][bottom(200)]|",
                "H:|[top]|",
                "H:|[center]|",
                "H:|[bottom]|")
            .constraints
        view.addConstraints(consts)
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
