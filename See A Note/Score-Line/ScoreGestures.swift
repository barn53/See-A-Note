//
//  ScoreGestures.swift
//  See A Note
//
//  Created by Gerd Müller on 15.09.15.
//  Copyright © 2015 Gerd Müller. All rights reserved.
//

import Foundation
import UIKit


class ScoreGestures {

    var scoreLineView: ScoreLineView!
    var editButton: ScoreEditButton!

    init(scoreLineView: ScoreLineView, editButton: ScoreEditButton) {
        self.scoreLineView = scoreLineView
        self.editButton = editButton

        let pan = UIPanGestureRecognizer(target: self, action: "panEvent:")
        editButton.addGestureRecognizer(pan)

        editButton.addTarget(self, action: "touchDownEvent:", forControlEvents: UIControlEvents.TouchDown)
        editButton.addTarget(self, action: "touchUpEvent:", forControlEvents: UIControlEvents.TouchUpInside)
        editButton.addTarget(self, action: "touchUpEvent:", forControlEvents: UIControlEvents.TouchUpOutside)
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
    var deletePosition = false
    let lowestPossibleLine = -2
    let lineWhichMeansDeletePosition = 14

    @objc func touchDownEvent(sender: UIButton) {
        scoreLineView.showCursor = true
    }
    @objc func touchUpEvent(sender: UIButton) {
        scoreLineView.showCursor = false
    }

    @objc func panEvent(sender: UIPanGestureRecognizer) {
        let point = sender.translationInView(nil)

        switch sender.state {
        case .Began:
            panInitial = point
            panPositionMode = true
            panLastChangeX = point.x
            panLastChangeY = point.y
            cancelNote = false

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
                        scoreLineView.nextPosition()
                    }
                    else if point.x < panLastChangeX - 15 {
                        panLastChangeX = point.x
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
                        if cancelNote == false && panAccidental == .DOUBLE_SHARP {
                            cancelNote = true
                        }
                        else {
                            panAccidental = panAccidental.next
                            cancelNote = false
                        }
                        panLastChangeX = point.x
                    }
                    else if point.x < panLastChangeX - 15 {
                        if !cancelNote {
                            panAccidental = panAccidental.previous
                        }
                        cancelNote = false
                        panLastChangeX = point.x
                    }

                    if point.y > panLastChangeY + 10 {
                        if panNoteLine > lowestPossibleLine {
                            panNoteLine--
                            deletePosition = false
                        }
                        cancelNote = false
                        panAccidental = scoreLineView.currentAccidentalAtCurrentEditPositionForLine(panNoteLine)
                        panLastChangeY = point.y
                    }
                    else if point.y < panLastChangeY - 10 {
                        if panNoteLine < lineWhichMeansDeletePosition {
                            panNoteLine++
                            if panNoteLine == lineWhichMeansDeletePosition {
                                deletePosition = true
                            }
                            else {
                                deletePosition = false
                            }
                        }
                        cancelNote = false
                        panAccidental = scoreLineView.currentAccidentalAtCurrentEditPositionForLine(panNoteLine)
                        panLastChangeY = point.y
                    }

                    if !deletePosition && !cancelNote {
                        scoreLineView.cursorView.cursorEditColor()
                        scoreLineView.showHoverHeadOnCursorOnLine(panNoteLine, accidental: panAccidental)
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
                        scoreLineView.addNoteToPosition(panNoteLine, accidental: panAccidental)
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

