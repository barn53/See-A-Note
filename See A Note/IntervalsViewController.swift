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

    @IBOutlet weak var titleBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let esDur: [[(line: Int, accidental: AccidentalSymbol)]] =
        [[(7, .FLAT)], [(8, .NATURAL)], [(9, .NATURAL)], [(10, .FLAT)],
         [(11, .FLAT)], [(12, .NATURAL)], [(13, .NATURAL)], [(14, .FLAT)]]

        scoreLineView.debugLabel = self.debugLabel
        scoreLineView.editButton = self.editButton.subviews[0] as? ScoreEditButton

        scoreLineView.scoreClef = .F
        scoreLineView.keySignature = .NATURAL

        for ii in esDur.indices {
            scoreLineView.setNotesForPosition(esDur[ii], head: .HALF, texts: ["es", "f#"])
            scoreLineView.nextPosition()
        }

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.whiteColor().CGColor,
            UIColor.purpleColor().CGColor]
        gradient.locations = [0.2 , 0.6]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        titleBar.layer.insertSublayer(gradient, atIndex: 0)
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

    override func viewWillLayoutSubviews() {
        if let sublayers = titleBar.layer.sublayers {
            for layer in sublayers {
                layer.frame = CGRect(x: 0.0, y: 0.0, width: titleBar.frame.size.width, height: titleBar.frame.size.height)
            }
        }
    }


    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        scoreLineView.setNeedsDisplay()
    }

}

