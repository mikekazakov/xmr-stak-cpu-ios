//
//  ViewController.swift
//  xmr-stak-cpu-ios
//
//  Created by Michael G. Kazakov on 10/22/17.
//  Copyright © 2017 Michael G. Kazakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onShowHashrate(_ sender: Any) {
        invoke_print_hash()
    }
    
}

