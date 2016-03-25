//
//  ScoreGestures.swift
//  See A Note
//
//  Created by Gerd Müller on 15.09.15.
//  Copyright © 2015 Gerd Müller. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class PanPressGestureRecognizer: UIPanGestureRecognizer {
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        if #available(iOS 9.0, *) {
            if let touch = touches.first {
                if touch.force >= touch.maximumPossibleForce / 1.5 {
                    pressed = true
                }

                if touch.force <= touch.maximumPossibleForce / 6 {
                    pressed = false
                    drewNote = false
                }
                debugLabel.text = "pressed: \(pressed), f: \(touch.force)"
            }
        }
        else {
            // Fallback on earlier versions
        }

        super.touchesMoved(touches, withEvent: event)
    }

    var debugLabel: UILabel!

    var pressed = false
    var drewNote = false
}

class ScoreGestures {

    var scoreLineView: ScoreLineView!
    var editButton: ScoreEditButton!

    init(scoreLineView: ScoreLineView, editButton: ScoreEditButton) {
        self.scoreLineView = scoreLineView
        self.editButton = editButton

        let pan = PanPressGestureRecognizer(target: self, action: #selector(ScoreGestures.panEvent(_:)))
        pan.debugLabel = scoreLineView.debugLabel
        editButton.addGestureRecognizer(pan)

        editButton.addTarget(self, action: #selector(ScoreGestures.touchDownEvent(_:)), forControlEvents: UIControlEvents.TouchDown)
        editButton.addTarget(self, action: #selector(ScoreGestures.touchUpEvent(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        editButton.addTarget(self, action: #selector(ScoreGestures.touchUpEvent(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
    }

    var panInitial: CGPoint!
    var panPositionMode = true
    var panLastChangeX: CGFloat!
    var panLastChangeY: CGFloat!
    var panAccidental = AccidentalSymbol.NATURAL
    var panClef = ClefSymbol.G
    var panKeySignature = KeySignature.NATURAL
    var panNoteLine = 6
    var cancelNote = false
    var drewNoteWithPress = false
    var deletePosition = false
    let lowestPossibleLine = -2
    let lineWhichMeansDeletePosition = 14

    @objc func touchDownEvent(sender: UIButton) {
        scoreLineView.showCursor = true
    }
    @objc func touchUpEvent(sender: UIButton) {
        scoreLineView.showCursor = false
    }

    @objc func panEvent(sender: PanPressGestureRecognizer) {
        let point = sender.translationInView(nil)

        switch sender.state {
        case .Began:
            panInitial = point
            panPositionMode = true
            panLastChangeX = point.x
            panLastChangeY = point.y
            cancelNote = false
            drewNoteWithPress = false

        case .Changed:

            if panPositionMode {
                if point.y > panInitial.y + 20 || point.y < panInitial.y - 20 {
                    panPositionMode = false
                    panInitial = point
                    panLastChangeX = point.x
                    panLastChangeY = point.y
                    panNoteLine = 6
                    panAccidental = scoreLineView.currentAccidentalAtCurrentEditPositionForLine(panNoteLine)
                    panClef = scoreLineView.scoreClef
                    panKeySignature = scoreLineView.keySignature
                }
                else {
                    if point.x > panLastChangeX + 15 {
                        panLastChangeX = point.x
                        panLastChangeY = point.y
                        scoreLineView.nextPosition()
                    }
                    else if point.x < panLastChangeX - 15 {
                        panLastChangeX = point.x
                        panLastChangeY = point.y
                        scoreLineView.previousPosition()
                    }
                }
            }
            else {
                if scoreLineView.editClef || scoreLineView.editKeySignature {
                    if point.y > panLastChangeY + 15 {
                        panLastChangeY = point.y
                        if scoreLineView.editClef {
                            panClef = panClef.next
                        }
                        else {
                            panKeySignature = panKeySignature.next
                        }
                    }
                    else if point.y < panLastChangeY - 15 {
                        panLastChangeY = point.y
                        if scoreLineView.editClef {
                            panClef = panClef.previous
                        }
                        else {
                            panKeySignature = panKeySignature.previous
                        }
                    }

                    if scoreLineView.editClef {
                        scoreLineView.cursorView.cursorEditColor()
                        scoreLineView.showHoverClefOnCursor(panClef)
                    }
                    else {
                        scoreLineView.cursorView.cursorEditColor()
                        scoreLineView.showHoverKeySignatureOnCursor(panKeySignature)
                    }
                }
                else {
                    if point.x > panLastChangeX + 15 {
                        panLastChangeY = point.y
                        panLastChangeX = point.x
                        if cancelNote == false && panAccidental == .DOUBLE_SHARP {
                            cancelNote = true
                        }
                        else {
                            panAccidental = panAccidental.next
                            cancelNote = false
                        }
                    }
                    else if point.x < panLastChangeX - 15 {
                        panLastChangeY = point.y
                        panLastChangeX = point.x
                        if !cancelNote {
                            panAccidental = panAccidental.previous
                        }
                        cancelNote = false
                    }

                    if point.y > panLastChangeY + 15 {
                        panLastChangeY = point.y
                        panLastChangeX = point.x
                        if panNoteLine > lowestPossibleLine {
                            panNoteLine -= 1
                            deletePosition = false
                        }
                        cancelNote = false
                        panAccidental = scoreLineView.currentAccidentalAtCurrentEditPositionForLine(panNoteLine)
                    }
                    else if point.y < panLastChangeY - 15 {
                        panLastChangeY = point.y
                        panLastChangeX = point.x
                        if panNoteLine < lineWhichMeansDeletePosition {
                            panNoteLine += 1
                            if panNoteLine == lineWhichMeansDeletePosition {
                                deletePosition = true
                            }
                            else {
                                deletePosition = false
                            }
                        }
                        cancelNote = false
                        panAccidental = scoreLineView.currentAccidentalAtCurrentEditPositionForLine(panNoteLine)
                    }

                    if sender.pressed && !sender.drewNote && !cancelNote {
                        scoreLineView.addNoteToPosition(panNoteLine, accidental: panAccidental)
                        AudioServicesPlaySystemSound(SystemSoundID(1306))
                        sender.drewNote = true
                        drewNoteWithPress = true
                    }

                    if !deletePosition && !cancelNote {
                        scoreLineView.cursorView.cursorEditColor()
                        scoreLineView.showHoverHeadOnCursorOnLine(panNoteLine, drewNoteByPress: sender.drewNote, accidental: panAccidental)
                    }
                    else if deletePosition{
                        scoreLineView.cursorView.cursorDeleteColor()
                        scoreLineView.hideHoverOnCursor()
                    }
                    else if cancelNote {
                        scoreLineView.cursorView.cursorEditCancelColor()
                        scoreLineView.hideHoverOnCursor()
                    }
                }
            }
        case .Ended:
            sender.setTranslation(CGPointMake(0.0, 0.0), inView: nil)
            scoreLineView.cursorView.cursorEditColor()
            scoreLineView.hideHoverOnCursor()
            scoreLineView.showCursor = false
            if !panPositionMode {
                if scoreLineView.editClef {
                    scoreLineView.scoreClef = panClef
                }
                else if scoreLineView.editKeySignature {
                    scoreLineView.keySignature = panKeySignature
                }
                else {
                    if panNoteLine == lineWhichMeansDeletePosition {
                        scoreLineView.removePosition()
                    }
                    else if !cancelNote {
                        if !drewNoteWithPress {
                            scoreLineView.addNoteToPosition(panNoteLine, accidental: panAccidental)
                        }
                    }
                }
            }
            scoreLineView.editKeySignature = false
            scoreLineView.editClef = false
            deletePosition = false
        default:
            sender.setTranslation(CGPointMake(0.0, 0.0), inView: nil)
            scoreLineView.cursorView.cursorEditColor()
            scoreLineView.hideHoverOnCursor()
            scoreLineView.showCursor = false
            scoreLineView.editKeySignature = false
            scoreLineView.editClef = false
        }
    }
}

