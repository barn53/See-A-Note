//
//  CursorView.swift
//  See A Note
//
//  Created by Gerd Müller on 13.10.15.
//  Copyright © 2015 Gerd Müller. All rights reserved.
//

import UIKit

class CursorView: UIView {

    let colorDraw = UIColor(redInt: 0x00, greenInt: 0x7a, blueInt: 0xff)
    let colorDrew = UIColor(redInt: 0x34, greenInt: 0xaa, blueInt: 0xdc)
    let colorDelete = UIColor(redInt: 0xff, greenInt: 0x3b, blueInt: 0x30)

    enum HeadStyle {
        case draw, drew, delete
    }

    var fontSize: CGFloat = 0.0
    var noteHeight: CGFloat = 0.0
    var yLine0: CGFloat = 0.0
    var lineWidth: CGFloat = 0.0

    var showHoverHead = false {
        didSet {
            if showHoverHead {
                showHoverClef = false
                showHoverKeySignature = false
            }
        }
    }
    var showHoverClef = false {
        didSet {
            if showHoverClef {
                showHoverHead = false
                showHoverKeySignature = false
            }
        }
    }
    var showHoverKeySignature = false {
        didSet {
            if showHoverKeySignature {
                showHoverHead = false
                showHoverClef = false
            }
        }
    }

    var clef: ClefSymbol = .G
    var keySignature: KeySignature = .NATURAL

    var noteHead: NoteHeadSymbol = .BLACK
    var accidental: AccidentalSymbol = .NATURAL
    var stemOffsetX: CGFloat?
    var stemDirection: ScoreLineView.StemDirection?
    var hoverHeadOnLine = 0
    var headStyle = HeadStyle.draw
    var noteColor = UIColor.blackColor()

    var attributes: [String : AnyObject]!

    func cursorEditColor() {
        self.backgroundColor = UIColor(redInt: 0x4c, greenInt: 0xd9, blueInt: 0x64, alpha: 0.4)
    }
    func cursorEditCancelColor() {
        self.backgroundColor = UIColor(redInt: 0x99, greenInt: 0x99, blueInt: 0x99, alpha: 0.4)
    }
    func cursorDeleteColor() {
        self.backgroundColor = UIColor(redInt: 0xff, greenInt: 0x3b, blueInt: 0x30, alpha: 0.4)
    }

    func drawLegersForLine(line: Int, beginX: CGFloat) {
        if line <= 0 {
            for var ii = 0; ii >= line; ii -= 2 {
                drawLeger(ii, beginX: beginX)
            }
        }
        if line >= 12 {
            for var ii = 12; ii <= line; ii += 2 {
                drawLeger(ii, beginX: beginX)
            }
        }
    }
    func drawLeger(line: Int, beginX: CGFloat) {
        let legerPath = UIBezierPath()
        legerPath.lineWidth = lineWidth * 1.3
        let y = yLine0 - noteHeight * CGFloat(CGFloat(line) / 2)

        let noteWidth = noteHead.glyph.sizeWithAttributes(attributes).width
        legerPath.moveToPoint(CGPoint(x: beginX - (noteWidth * 0.3), y: y))
        legerPath.addLineToPoint(CGPoint(x: beginX + (noteWidth * 1.39), y: y))
        noteColor.setStroke()
        legerPath.stroke()
    }

    override func drawRect(rect: CGRect) {
        if showHoverHead {
            switch headStyle {
            case .draw:
                noteColor = colorDraw
            case .drew:
                noteColor = colorDrew
            case .delete:
                noteColor = colorDelete
            }

            attributes = [
                NSForegroundColorAttributeName: noteColor,
                NSFontAttributeName: UIFont(name: "BravuraText", size: fontSize)!
            ]

            var glyphs = accidental.glyph as String
            glyphs += noteHead.glyph as String

            var beginX: CGFloat = 0.0
            if let stemOffsetX = stemOffsetX {
                if let stemDirection = stemDirection {
                    beginX = stemOffsetX - accidental.glyph.sizeWithAttributes(attributes).width + AccidentalSymbol.DOUBLE_FLAT.glyph.sizeWithAttributes(attributes).width - noteHead.glyph.sizeWithAttributes(attributes).width
                    if stemDirection == .DOWN {
                        beginX += noteHead.glyph.sizeWithAttributes(attributes).width
                    }
                }
            }
            else {
                beginX = (self.bounds.width / 2) - (glyphs.sizeWithAttributes(attributes).width / 2)
            }
            drawLegersForLine(hoverHeadOnLine, beginX: beginX + accidental.glyph.sizeWithAttributes(attributes).width)
            glyphs.drawAtPoint(CGPointMake(beginX, (yLine0 - ((CGFloat(hoverHeadOnLine) + 4) * noteHeight) / 2)), withAttributes: attributes)
        }
        else if showHoverClef {
            attributes = [
                NSForegroundColorAttributeName: colorDraw,
                NSFontAttributeName: UIFont(name: "BravuraText", size: fontSize)!
            ]
            clef.glyph.drawAtPoint(CGPointMake(lineWidth * 5, yLine0 - (5 * noteHeight)), withAttributes: attributes)
        }
        else if showHoverKeySignature {
            attributes = [
                NSForegroundColorAttributeName: colorDraw,
                NSFontAttributeName: UIFont(name: "BravuraText", size: fontSize)!
            ]

            var accidentalX: CGFloat = 0.0
            var accidentalY: CGFloat = 0.0

            if keySignature != .NATURAL {
                for ii in keySignature.lines {
                    let line = ii + clef.lineDeltaKeySignatureToGClef
                    accidentalY = yLine0 - noteHeight * CGFloat(CGFloat(line + 4) / 2)
                    keySignature.accidental.glyph.drawAtPoint(CGPointMake(accidentalX, accidentalY), withAttributes: attributes)
                    accidentalX += keySignature.accidental.glyph.sizeWithAttributes(attributes).width * 0.9
                }
            }
        }
    }
}

