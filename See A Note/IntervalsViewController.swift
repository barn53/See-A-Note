//
//  IntervalsViewController
//  See A Note
//
//  Created by Gerd Müller on 31.08.15.
//  Copyright © 2015 Gerd Müller. All rights reserved.
//

import UIKit
import AVFoundation

class IntervalsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        var esDur: [[(line: Int, accidental: AccidentalSymbol)]] =
            [[(7, .FLAT)], [(8, .NATURAL)], [(9, .NATURAL)], [(10, .FLAT)],
             [(11, .FLAT)], [(12, .NATURAL)], [(13, .NATURAL)], [(14, .FLAT)]]
        
        esDur = [[(2, .FLAT)], [(8, .FLAT)]]
        
        scoreLineView.debugLabel = self.debugLabel
        scoreLineView.editButton = self.editButton.subviews[0] as? ScoreEditButton

        scoreLineView.scoreClef = .F
        scoreLineView.keySignature = .NATURAL
        scoreLineView.widthFactor = 2

        for ii in esDur.indices {
            scoreLineView.setNotesForPosition(esDur[ii], head: .HALF, texts: ["es", "f#"])
            scoreLineView.nextPosition()
        }
    }

    @IBOutlet weak var scoreLineView: ScoreLineView!
    @IBOutlet weak var editButton: ScoreEditButtonView!

    @IBOutlet weak var debugLabel: UILabel!

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

