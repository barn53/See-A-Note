//
//  OptionsViewController.swift
//  See A Note
//
//  Created by Gerd Müller on 13.10.15.
//  Copyright © 2015 Gerd Müller. All rights reserved.
//

import UIKit

class OptionsViewController: UITableViewController {

    @IBAction func cancelTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
