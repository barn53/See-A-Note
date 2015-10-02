//
//  ViewController.swift
//  See A Note
//
//  Created by Gerd Müller on 31.08.15.
//  Copyright © 2015 Gerd Müller. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let optimizedAccidentals: [(line: Int, accidental: AccidentalSymbol)] =
        [(14, .FLAT), (6, .SHARP), (-2, .FLAT)]

        let accidentals: [(line: Int, accidental: AccidentalSymbol)] =
        [(4, .FLAT), (6, .SHARP), (8, .FLAT)]

        let accidentals2: [(line: Int, accidental: AccidentalSymbol)] =
        [(10, .FLAT), (6, .SHARP), (2, .FLAT)]

        let stemDownNoShift: [(line: Int, accidental: AccidentalSymbol)] =
        [(11, .FLAT), (9, .NATURAL), (7, .FLAT)] // stem down, no shift

        let stemDownShift: [(line: Int, accidental: AccidentalSymbol)] =
        [(11, .FLAT), (9, .NATURAL), (8, .FLAT)] // stem down, no shift

        let stemUpNoShift: [(line: Int, accidental: AccidentalSymbol)] =
        [(1, .FLAT), (3, .NATURAL), (6, .FLAT)] // stem down, no shift

        let stemUpShift: [(line: Int, accidental: AccidentalSymbol)] =
        [(1, .FLAT), (4, .NATURAL), (5, .FLAT)] // stem down, no shift

        let seven: [(line: Int, accidental: AccidentalSymbol)] =
        [(12, .FLAT), (10, .FLAT), (8, .FLAT), (6, .FLAT),
            (4, .FLAT), (2, .FLAT), (0, .FLAT)]

        let five: [(line: Int, accidental: AccidentalSymbol)] =
        [(10, .FLAT), (8, .FLAT), (6, .FLAT), (4, .FLAT), (2, .FLAT)]

        scoreLineView.editButton = self.editButton.subviews[0] as! ScoreEditButton

        scoreLineView.scoreClef = .F
        scoreLineView.keySignature = .FLAT_3

        scoreLineView.setNotesForPosition(accidentals)
        scoreLineView.setMeasureLineForPosition()

    }

    @IBOutlet weak var scoreLineView: ScoreLineView!
    @IBOutlet weak var editButton: ScoreEditButtonView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func toggleDebug(sender: UIButton) {
        scoreLineView.debugColor = !scoreLineView.debugColor
        scoreLineView.setNeedsDisplay()
    }


    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        scoreLineView.setNeedsDisplay()
    }

}

