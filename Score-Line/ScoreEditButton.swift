//
//  ScoreEditButton.swift
//  See A Note
//
//  Created by Gerd Müller on 15.09.15.
//  Copyright © 2015 Gerd Müller. All rights reserved.
//

import UIKit

@IBDesignable class ScoreEditButtonView: UIView {

    @IBInspectable var color:UIColor = UIColor(redInt: 0xff, greenInt: 0x95, blueInt: 0x00)

    #if TARGET_INTERFACE_BUILDER
    override func willMoveToSuperview(newSuperview: UIView?) {
        let button: ScoreEditButton = ScoreEditButton(color: self.color, frame: self.bounds)
        self.addSubview(button)

    }
    #else
    override func awakeFromNib() {
        super.awakeFromNib()
        let button:ScoreEditButton = ScoreEditButton(color: self.color, frame: self.bounds)
        self.addSubview(button)
    }
    #endif

}

class ScoreEditButton: UIControl {

    var color: UIColor!

    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        // sowas wie highlighted image anzeigen
        return true
    }


    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        return true
    }

    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
        // wieder normales image anzeigen
    }

    convenience init(color: UIColor, frame: CGRect) {
        self.init(frame: frame)
        self.color = color
        self.backgroundColor = UIColor.clearColor()
        self.opaque = true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        let attributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: UIFont(name: "BravuraText", size: 60)!
        ]

        let icon: NSString = "♩"
        icon.drawAtPoint(CGPointMake(self.bounds.width / 2, self.bounds.height / 2), withAttributes: attributes)
    }

}
