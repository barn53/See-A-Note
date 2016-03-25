//
//  ScoreLineView
//  See A Note
//
//  Created by Gerd Müller on 31.08.15.
//  Copyright © 2015 Gerd Müller. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(redInt: Int, greenInt: Int, blueInt: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(redInt) / 255, green: CGFloat(greenInt) / 255, blue: CGFloat(blueInt) / 255, alpha: alpha)
    }
}

@IBDesignable class ScoreLineView: UIView {

    // MARK: Members
    var debugLabel: UILabel!

    @IBInspectable var fontSize: CGFloat = 75
    @IBInspectable var notesColor: UIColor = UIColor(redInt: 0x00, greenInt: 0x00, blueInt: 0x00)
    @IBInspectable var debugColor: Bool = false
    @IBInspectable var drawParenthesizedAccidentals: Bool = true
    var editPosition = 0

    var _editKeySignature = false
    var editKeySignature: Bool {
        get { return _editKeySignature }
        set {
            if editPosition == 0 {
                _editKeySignature = newValue
                _editClef = newValue ? false : _editClef
            }
        }
    }
    var _editClef = false
    var editClef: Bool {
        get { return _editClef }
        set {
            if editPosition == 0 {
                _editClef = newValue
                _editKeySignature = newValue ? false : _editKeySignature
            }
        }
    }

    var gestures: ScoreGestures!
    var editButton: ScoreEditButton? {
        get {
            return gestures.editButton
        }
        set {
            if let editButton = newValue {
                gestures = ScoreGestures(scoreLineView: self, editButton: editButton)
            }
        }

    }

    var widthFactor: CGFloat = 1.0

    var baseAccidentalsKeySignature: [Int : AccidentalSymbol] = [:]
    var lineAccidentalsCurrentMeasure: [Int : AccidentalSymbol] = [:]

    var attributes: [String : AnyObject]!
    var attributesText: [String : AnyObject]!

    let cursorView = CursorView(frame: CGRectMake(5, 5, 100, 40))

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fontSize = CGRectGetHeight(self.bounds) / 5

        cursorView.cursorEditColor()
        self.addSubview(cursorView)
    }

    func calcWidthForGlyph(glyph: NSString) -> CGFloat {
        return glyph.sizeWithAttributes(attributes).width
    }
    var noteHeight: CGFloat {
        // this is an approximated factor
        return fontSize * 0.198
    }
    var lineWidth: CGFloat {
        return fontSize / 50
    }
    var stemWidth: CGFloat {
        return fontSize / 50
    }
    var yLine0: CGFloat {
        // this is an approximated factor
        return (drawingPoint.y - fontSize * 0.192) + 6 * noteHeight
    }
    var yNoteLine0: CGFloat {
        // this is an approximated factor
        return (drawingPoint.y - fontSize * 0.198) + 4 * noteHeight
    }
    
    var drawingPoint: CGPoint = CGPointMake(0, 0)

    var scoreClef: ClefSymbol = .G {
        didSet {
            // 'transpose' all notes to new clef
            for position in notesForDisplay.indices {
                for note in notesForDisplay[position].notes.indices {
                    var lineDelta = oldValue.lineDeltaTransposeToGClef
                    lineDelta -= scoreClef.lineDeltaTransposeToGClef
                    notesForDisplay[position].notes[note].line += lineDelta
                }
            }
            setNeedsDisplay()
        }
    }
    var keySignature: KeySignature = .NATURAL {
        didSet {
            setNeedsDisplay()
        }
    }
    var notesForDisplay: [NotesForDisplay] = []

    @IBInspectable var showCursor = false {
        didSet {
            moveCursor()
        }
    }

    func reset() {
        baseAccidentalsKeySignature = [:]
        lineAccidentalsCurrentMeasure = [:]

        // this is an approximated divisor
        drawingPoint = CGPointMake(lineWidth * 5, self.bounds.height / 2.72 )

        attributes = [
            NSForegroundColorAttributeName: notesColor,
            // http://codewithchris.com/common-mistakes-with-adding-custom-fonts-to-your-ios-app/
            NSFontAttributeName: UIFont(name: "BravuraText", size: fontSize)!
        ]

        attributesText = [
            NSForegroundColorAttributeName: notesColor,
            NSFontAttributeName: UIFont.systemFontOfSize(fontSize / 3.5)
        ]
    }

    // MARK: drawing functions

    func markDrawingPoint(color: UIColor = UIColor.redColor()) {
        if debugColor {
            let path = UIBezierPath()
            path.lineWidth = 0.2
            path.moveToPoint(CGPointMake(drawingPoint.x, 0))
            path.addLineToPoint(CGPointMake(drawingPoint.x, self.bounds.height))
            color.setStroke()
            path.stroke()
        }
    }

    /*
    ------------------  <-- Line 10
    ------------------  <-- Line 8
    ------------------  <-- Line 6
    ------------------  <-- Line 4
    ------------------  <-- Line 2
        -O-  <-- Line 0
    */
    func drawLines() {
        for ii in 1...5 {
            let path = UIBezierPath()
            path.lineWidth = lineWidth

            let y: CGFloat = yLine0 - (CGFloat(ii) * noteHeight)

            path.moveToPoint(CGPointMake(0, y))
            path.addLineToPoint(CGPointMake(self.bounds.width, y))
            notesColor.setStroke()
            if debugColor { UIColor.purpleColor().setStroke() }
            path.stroke()
        }

        // start bar
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        path.moveToPoint(CGPointMake(lineWidth / 2, yLine0 - noteHeight))
        path.addLineToPoint(CGPointMake(lineWidth / 2, yLine0 - 5 * noteHeight))
        notesColor.setStroke()
        if debugColor { UIColor.orangeColor().setStroke() }
        path.stroke()

        drawMeasureLine(.VIEW_END)
    }

    func drawClef() {
        markDrawingPoint()
        let clefGlyph = scoreClef.glyph
        clefGlyph.drawAtPoint(CGPointMake(drawingPoint.x, drawingPoint.y), withAttributes: attributes)

        drawingPoint.x += calcWidthForGlyph(clefGlyph) * 1.2
    }

    func drawLegersForLine(line: Int, note: NoteHeadSymbol) {
        let noteWidth = calcWidthForGlyph(note.glyph)

        if line <= 0 {
            for var ii = 0; ii >= line; ii -= 2 {
                drawLeger(ii, noteWidth: noteWidth)
            }
        }
        if line >= 12 {
            for var ii = 12; ii <= line; ii += 2 {
                drawLeger(ii, noteWidth: noteWidth)
            }
        }

    }
    func drawLeger(line: Int, noteWidth: CGFloat) {
        let legerPath = UIBezierPath()
        legerPath.lineWidth = lineWidth * 1.3
        let y = yLine0 - noteHeight * CGFloat(CGFloat(line) / 2)

        legerPath.moveToPoint(CGPoint(x: drawingPoint.x - (noteWidth * 0.3), y: y))
        legerPath.addLineToPoint(CGPoint(x: drawingPoint.x + (noteWidth * 1.39), y: y))
        notesColor.setStroke()
        if debugColor { UIColor.redColor().setStroke() }
        legerPath.stroke()
    }

    func calcAccidentalBaseLineFor(line: Int) -> Int {
        var baseLine = line % 7
        if baseLine < 0 {
            baseLine = ((line - 7) % 7) + 7
        }
        return baseLine
    }

    func currentAccidentalAtCurrentEditPositionForLine(line: Int) -> AccidentalSymbol {
        let baseLine = calcAccidentalBaseLineFor(line)

        var keySignatureAccidental = AccidentalSymbol.NONE
        if let acc = baseAccidentalsKeySignature[baseLine] {
            keySignatureAccidental = acc
        }
        var ret = keySignatureAccidental

        for position in 0...editPosition {
            if position > 0 && notesForDisplay[position - 1].measureLine != nil {
                ret = keySignatureAccidental
            }

            for note in notesForDisplay[position].notes {
                if note.line == line {
                    if note.accidental != .NONE {
                        ret = note.accidental
                    }
                }
            }
        }
        return ret
    }
    
    func effectiveAccidentalForLine(line: Int, wantAccidental: AccidentalSymbol) -> AccidentalSymbol {
        let baseLine = calcAccidentalBaseLineFor(line)

        var effectiveAccidental = AccidentalSymbol.NONE
        if let ksa = baseAccidentalsKeySignature[baseLine] {
            effectiveAccidental = ksa
        }
        if let cla = lineAccidentalsCurrentMeasure[line] {
            if cla != .NONE {
                effectiveAccidental = cla
            }
        }

        if wantAccidental != effectiveAccidental && !(wantAccidental == .NATURAL && effectiveAccidental == .NONE) {
            return wantAccidental
        }
        return .NONE
    }

    func drawNoteOnLine(line: Int, head: NoteHeadSymbol = .BLACK) -> CGFloat {
        markDrawingPoint(UIColor.blackColor())

        let y = yNoteLine0 - noteHeight * CGFloat(CGFloat(line) / 2)
        head.glyph.drawAtPoint(CGPointMake(drawingPoint.x, y), withAttributes: attributes)

        drawLegersForLine(line, note: head)

        return drawingPoint.x + calcWidthForGlyph(head.glyph) * 1.5 * widthFactor
    }
    
    func drawSpace() {
        markDrawingPoint()
        drawingPoint.x += calcWidthForGlyph(NoteHeadSymbol.WHOLE.glyph) * widthFactor
    }

    func drawRest(rest: RestSymbol) {
        markDrawingPoint()
        let y = yNoteLine0 - noteHeight * 3
        rest.glyph.drawAtPoint(CGPointMake(drawingPoint.x, y), withAttributes: attributes)
        let restWidth = calcWidthForGlyph(rest.glyph)
        drawingPoint.x += restWidth * 2
    }

    enum StemDirection {
        case UP, DOWN
    }

    func drawNotesAtPosition(position: Int) {
        let notes = notesForDisplay[position].notes
        let head = notesForDisplay[position].head

        if notes.count == 0 {
            return
        }

        var maxTextWidth = CGFloat(0)
        for text: NSString in notesForDisplay[position].texts {
            maxTextWidth = max(maxTextWidth, text.sizeWithAttributes(attributesText).width)
        }

        var notesDistinct: [(line: Int, accidental: AccidentalSymbol)] = []
        var occupiedLines = Set<Int>()
        for note in notes {
            if !occupiedLines.contains(note.line) {
                notesDistinct.append(note)
            }
            occupiedLines.insert(note.line)
        }
        // draw it top-down
        notesDistinct = notesDistinct.sort {$0.0 > $1.0}

        var effectiveAccidentals: [(line: Int, accidental: AccidentalSymbol)] = []
        var stemDirection = StemDirection.DOWN
        var stemCount = 0
        var needShift = false

        // collect info
        var previousLine: Int?
        for note in notesDistinct {
            let acc = effectiveAccidentalForLine(note.line, wantAccidental: note.accidental)
            if  acc != .NONE {
                effectiveAccidentals.append((note.line, acc))
            }
            stemCount += 6 - note.line
            if let previousLine = previousLine {
                if note.line + 1 == previousLine {
                    needShift = true
                }
            }
            previousLine = note.line
        }
        let upperLine = notesDistinct.first!.line
        let lowerLine = notesDistinct.last!.line

        if stemCount > 0 {
            stemDirection = .UP
        }

        let originX = drawingPoint.x
        let accidentalsWidth = drawAccidentalsRuleBased(effectiveAccidentals)
        drawingPoint.x += accidentalsWidth

        // then all heads
        let headWidth = calcWidthForGlyph(head.glyph)
        let shiftX = calcWidthForGlyph(head.glyph) - stemWidth
        let beginX = drawingPoint.x
        var shiftedStartX = beginX
        var stemX = beginX + calcWidthForGlyph(head.glyph)
        var width = headWidth * 1.9 * widthFactor
        previousLine = nil
        var previousShifted = false

        if stemDirection == .UP {
            // draw it bottom-up
            notesDistinct = notesDistinct.sort {$0.0 < $1.0}
            stemX -= stemWidth / 2
        }
        else {
            // draw it top-down
            if needShift {
                // begin with a shifted head
                shiftedStartX = beginX + shiftX
                drawingPoint.x = shiftedStartX
                stemX = beginX + shiftX
            }
            else {
                stemX = beginX
            }
            stemX += stemWidth / 2
        }
        if needShift {
            width += shiftX
        }

        for note in notesDistinct {
            let line = note.line
            if let previousLine = previousLine {
                if ((previousLine + 1 == line && stemDirection == .UP) ||
                    (previousLine - 1 == line && stemDirection == .DOWN) ) &&
                    !previousShifted {
                    if stemDirection == .DOWN {
                        drawingPoint.x -= shiftX
                    }
                    else {
                        drawingPoint.x += shiftX
                    }
                    previousShifted = true
                }
                else {
                    previousShifted = false
                }
            }
            drawNoteOnLine(line, head: head)
            drawingPoint.x = shiftedStartX
            previousLine = line
        }

        notesForDisplay[position].stemDirection = stemDirection
        notesForDisplay[position].stemOffsetX = stemX - originX

        //draw stem
        if head == .BLACK || head == .HALF {
            drawingPoint.x = stemX
            notesForDisplay[position].lowestY = drawStem(stemDirection, upperLine: upperLine, lowerLine: lowerLine).lowerY
        }
        else {
            notesForDisplay[position].lowestY = yLine0
        }

        width = max(width, maxTextWidth)

        drawingPoint.x = beginX + width
    }

    func drawStem(stemDirection: StemDirection, upperLine: Int, lowerLine: Int) -> (upperY: CGFloat, lowerY: CGFloat) {
        markDrawingPoint(UIColor.blueColor())
        let path = UIBezierPath()
        path.lineWidth = stemWidth

        let x = drawingPoint.x
        var upperY = CGFloat(0)
        var lowerY = CGFloat(0)

        if stemDirection == .UP {
            upperY = yLine0 - (CGFloat(upperLine + 7) * (noteHeight / 2))
            lowerY = yLine0 - (noteHeight / 5) - (CGFloat(lowerLine) * (noteHeight / 2))
            path.moveToPoint(CGPointMake(x, upperY))
            path.addLineToPoint(CGPointMake(x, lowerY))
        }
        else {
            upperY = yLine0 + (noteHeight / 5) - (CGFloat(upperLine) * (noteHeight / 2))
            lowerY = yLine0 - (CGFloat(lowerLine - 7) * (noteHeight / 2))
            path.moveToPoint(CGPointMake(x, upperY))
            path.addLineToPoint(CGPointMake(x, lowerY))
        }
        notesColor.setStroke()
        if debugColor { UIColor.blueColor().setStroke() }
        path.stroke()

        return (upperY: upperY, lowerY: lowerY)
    }

    func drawMeasureLine(style: MeasureLineStyle = .SINGLE, clearLineEnd: Bool = false) {
        lineAccidentalsCurrentMeasure = [:]

        notesColor.setStroke()
        if debugColor { UIColor.orangeColor().setStroke() }

        var barWidth: CGFloat = 0.0
        var barX = self.bounds.width

        if style == .END || style == .VIEW_END {

            if style == .END {
                barX = drawingPoint.x + lineWidth * 20 * widthFactor
            }
            markDrawingPoint()
            var path = UIBezierPath()
            path.lineWidth = lineWidth * 7
            path.moveToPoint(CGPointMake(barX - path.lineWidth / 2, yLine0 - noteHeight))
            path.addLineToPoint(CGPointMake(barX - path.lineWidth / 2, yLine0 - 5 * noteHeight))
            path.stroke()

            path = UIBezierPath()
            path.lineWidth = lineWidth
            path.moveToPoint(CGPointMake(barX - lineWidth * 11, yLine0 - noteHeight))
            path.addLineToPoint(CGPointMake(barX - lineWidth * 11, yLine0 - 5 * noteHeight))
            path.stroke()

            if style == .END {
                barWidth += lineWidth * 35
            }
        }
        else if style == .SINGLE || style == .DOUBLE {
            barX = drawingPoint.x + lineWidth * 7 * widthFactor
            markDrawingPoint()
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            path.moveToPoint(CGPointMake(barX - path.lineWidth / 2, yLine0 - noteHeight))
            path.addLineToPoint(CGPointMake(barX - path.lineWidth / 2, yLine0 - 5 * noteHeight))
            path.stroke()

            if true && style == .DOUBLE {
                barX = barX + lineWidth * 6
                path.lineWidth = lineWidth
                path.moveToPoint(CGPointMake(barX - path.lineWidth / 2, yLine0 - noteHeight))
                path.addLineToPoint(CGPointMake(barX - path.lineWidth / 2, yLine0 - 5 * noteHeight))
                path.stroke()
                barWidth += lineWidth * 8
            }
            barWidth += lineWidth * 24
        }
        else {
            barX = drawingPoint.x + lineWidth * 12
            barWidth += lineWidth * 8
        }

        if clearLineEnd {
            let ctx = UIGraphicsGetCurrentContext()
            //CGContextClearRect(ctx, CGRectMake(barX, 0, self.bounds.width - barX, self.bounds.height))
            CGContextClearRect(ctx, CGRectMake(barX, 0, self.bounds.width - barX, self.bounds.height))
        }

        drawingPoint.x += barWidth * widthFactor
    }

    func calcWidthForAccidentalGlyph(glyph: NSString) -> CGFloat {
        return calcWidthForGlyph(glyph) + calcWidthForGlyph(AccidentalSymbol.SHARP.glyph) / 3
    }

    func drawAccidentalsRuleBased(accidentals: [(line: Int, accidental: AccidentalSymbol)]) -> CGFloat {
        var accidentalForPosition = ((accidentals.count + (accidentals.count % 2)) / 2) - 1
        var direction = (accidentals.count % 2) == 0 ? -1 : 1

        var accidentalIndexForPosition = [Int](count: accidentals.count, repeatedValue: 0)
        var widthsForPosition = [CGFloat](count: accidentals.count, repeatedValue: 0.0)
        var optimizedPositionForPosition = [Int](count: accidentals.count, repeatedValue: 0)

        for position in 0..<accidentalIndexForPosition.count {
            accidentalForPosition = (position * direction) + accidentalForPosition
            accidentalIndexForPosition[position] = accidentalForPosition
            let currentAccidental = accidentals[accidentalForPosition]
            var currentGlyphWidth = calcWidthForAccidentalGlyph(currentAccidental.accidental.glyph)
            if position < accidentals.count - 1 {
                currentGlyphWidth *= 0.9
            }
            widthsForPosition[position] = currentGlyphWidth

            optimizedPositionForPosition[position] = position
            for optimizedPosition in 0..<position {

                let previousAccidental = accidentals[accidentalIndexForPosition[optimizedPosition]]

                if (previousAccidental.line > currentAccidental.line + 5 ) {
                    optimizedPositionForPosition[position] = optimizedPosition
                    widthsForPosition[optimizedPosition] = max(widthsForPosition[position
                        ], widthsForPosition[optimizedPosition])
                    widthsForPosition[position] = 0.0
                    break
                }

                if (previousAccidental.line < currentAccidental.line - 5 ) {
                    optimizedPositionForPosition[position] = optimizedPosition
                    widthsForPosition[optimizedPosition] = max(widthsForPosition[position
                        ], widthsForPosition[optimizedPosition])
                    widthsForPosition[position] = 0.0
                    break
                }
            }

            direction *= -1
        }

        let startX = drawingPoint.x
        var position = 0
        for index in accidentalIndexForPosition {
            let accidental = accidentals[index]
            let optimizedPosition = optimizedPositionForPosition[position]
            if optimizedPosition != position {
                drawingPoint.x = startX
                for ii in 0..<optimizedPosition {
                    drawingPoint.x += widthsForPosition[ii]
                }
            }
            drawAccidentalOnLine(accidental.line, accidental: accidental.accidental)
            drawingPoint.x += widthsForPosition[optimizedPosition]
            position += 1
        }

        var width: CGFloat = 0.0
        for posWith in widthsForPosition {
            width += posWith
        }
        drawingPoint.x = startX
        return width
    }

    func drawAccidentalOnLine(line: Int, accidental: AccidentalSymbol) -> CGFloat {
        markDrawingPoint(UIColor.magentaColor())
        var width:CGFloat = 0.0
        if (accidental != .NONE) {
            lineAccidentalsCurrentMeasure[line] = accidental
            let glyph = accidental.glyph
            let y = yNoteLine0 - noteHeight * CGFloat(CGFloat(line) / 2)
            let x = drawingPoint.x
            glyph.drawAtPoint(CGPointMake(x, y), withAttributes: attributes)
            width = calcWidthForAccidentalGlyph(glyph)
        }
        return width
    }
    
    func drawKeySignature() {
        if keySignature != .NATURAL {
            for ii in keySignature.lines {
                markDrawingPoint()
                let line = ii + scoreClef.lineDeltaKeySignatureToGClef
                drawAccidentalOnLine(line, accidental: keySignature.accidental)
                baseAccidentalsKeySignature[calcAccidentalBaseLineFor(line)] = keySignature.accidental
                drawingPoint.x += calcWidthForGlyph(keySignature.accidental.glyph) * 0.9
            }
            drawingPoint.x += calcWidthForGlyph(keySignature.accidental.glyph) * 1.5 * widthFactor
        }
        else {
            drawingPoint.x += calcWidthForGlyph(AccidentalSymbol.SHARP.glyph) * 0.7 * widthFactor
        }
    }


    override func drawRect(rect: CGRect) {
        // Setup graphics context
        let ctx = UIGraphicsGetCurrentContext()
        CGContextClearRect(ctx, rect)

        reset()
        drawLines()
        drawClef()
        drawKeySignature()
        drawNotes()
        drawTexts()
        markDrawingPoint()
    }

    func drawNotes() {
        for position in notesForDisplay.indices {
            notesForDisplay[position].beginX = drawingPoint.x

            if notesForDisplay[position].notes.count > 0 {
                drawNotesAtPosition(position)
            }
            else if let measureLine = notesForDisplay[position].measureLine {
                drawMeasureLine(measureLine.style, clearLineEnd: measureLine.clearLineEnd)
            }
            else if notesForDisplay[position].space {
                drawSpace()
            }
            notesForDisplay[position].width = max(drawingPoint.x - notesForDisplay[position].beginX!, calcWidthForGlyph(NoteHeadSymbol.WHOLE.glyph))
        }
        moveCursor()
    }
    
    func drawTexts() {
        for position in notesForDisplay.indices {
            var textX = notesForDisplay[position].beginX!
            if let offset = notesForDisplay[position].stemOffsetX {
                textX += offset
            }
            if let stemDirection = notesForDisplay[position].stemDirection {
                if stemDirection == .UP {
                    textX -= calcWidthForGlyph(notesForDisplay[position].head.glyph) / 2
                }
            }
            var t = ""
            for text in notesForDisplay[position].texts {
                t = "\(t)\(text)\n"
            }
            let text: NSString = t
            let x = textX - text.sizeWithAttributes(attributesText).width / 2
            var y = yLine0 - noteHeight
            if let lowestY = notesForDisplay[position].lowestY {
                y = max(y, lowestY)
            }
            y += noteHeight / 2
            text.drawAtPoint(CGPointMake(x, y), withAttributes: attributesText)
        }
    }
    
    struct NotesForDisplay {
        var head: NoteHeadSymbol = .BLACK
        var notes: [(line: Int, accidental: AccidentalSymbol)] = []
        var texts: [String] = []
        var measureLine: (style: MeasureLineStyle, clearLineEnd: Bool)?
        var space = false
        // measures for cursor
        var beginX: CGFloat?
        var stemOffsetX: CGFloat?
        var stemDirection: StemDirection?
        var lowestY: CGFloat?
        var width: CGFloat?
    }
    
}

// MARK: API

extension ScoreLineView {

    func clearScore() {
        notesForDisplay = [NotesForDisplay()]
        editPosition = 0
        setNeedsDisplay()
    }

    func clearPosition() {
        if notesForDisplay.count > 0 {
            notesForDisplay[editPosition] = NotesForDisplay()
        }
    }
    func removePosition() {
        if notesForDisplay.count > 0 {
            notesForDisplay.removeAtIndex(editPosition)
        }
        if notesForDisplay.count == 0 {
            notesForDisplay = [NotesForDisplay()]
        }
        editPosition = max(0, min(notesForDisplay.count - 1, editPosition))
        setNeedsDisplay()
    }
    func insertPosition() {
        notesForDisplay.insert(NotesForDisplay(), atIndex: editPosition)
        setNeedsDisplay()
    }
    func nextPosition() {
        if !editClef && editKeySignature && editPosition == 0 {
            editKeySignature = false
            moveCursor()
        }
        else if editClef && !editKeySignature && editPosition == 0 {
            editKeySignature = true
            moveCursor()
        }
        else if notesForDisplay.count == 0  {
            notesForDisplay.append(NotesForDisplay())
            editPosition = notesForDisplay.count - 1
            setNeedsDisplay()
        }
        else if editPosition == (notesForDisplay.count - 1) {
            if notesForDisplay[editPosition].notes.count > 0 ||
                notesForDisplay[editPosition].measureLine != nil ||
                notesForDisplay[editPosition].space {
                    notesForDisplay.append(NotesForDisplay())
                    editPosition = notesForDisplay.count - 1
                    setNeedsDisplay()
            }
        }
        else if editPosition < (notesForDisplay.count - 1) {
            editPosition += 1
            moveCursor()
        }
    }
    func previousPosition() {
        if editPosition > 0 {
            editPosition -= 1
        }
        else if editPosition == 0 {
            if !editClef && !editKeySignature {
                editKeySignature = true
            }
            else if !editClef && editKeySignature {
                editClef = true
            }
        }
        moveCursor()
    }
    func lastPosition() {
        editPosition = notesForDisplay.count - 1
        moveCursor()
    }
    func setPosition(newPosition: Int) {
        if newPosition >= 0 && newPosition < notesForDisplay.count {
            editPosition = newPosition
        }
        moveCursor()
    }
    func translatePointToPosition(point: CGPoint) -> Int? {
        var ret: Int?
        for pp in notesForDisplay.indices {
            if let beginX = notesForDisplay[pp].beginX {
                if let width = notesForDisplay[pp].width {
                    if point.x >= beginX && point.x <= beginX + width {
                        ret = pp
                        break;
                    }
                }
            }
        }
        return ret
    }
    func pointAtEnd(point: CGPoint) -> Bool {
        return point.x >= drawingPoint.x
    }

    func notesAtPosition() -> [(line: Int, accidental: AccidentalSymbol)] {
        var ret: [(line: Int, accidental: AccidentalSymbol)] = []
        for note in notesForDisplay[editPosition].notes {
            ret.append((line: note.line, accidental: note.accidental))
        }
        ret.sortInPlace({$0.line > $1.line})
        return ret
    }

    func addNoteToPosition(line: Int, accidental: AccidentalSymbol = .NATURAL) {
        if notesForDisplay.count == 0 {
            nextPosition()
        }

        if let indexForNoteOnLine = notesForDisplay[editPosition].notes.indexOf( { $0.line == line } ) {
            if notesForDisplay[editPosition].notes.count == 1 {
                notesForDisplay[editPosition].notes = [(line: line, accidental: accidental)]
            }
            else {
                let currentAccidentalBeforeEdit = currentAccidentalAtCurrentEditPositionForLine(line)
                notesForDisplay[editPosition].notes.removeAtIndex(indexForNoteOnLine)
                if accidental != currentAccidentalBeforeEdit &&
                    !(accidental == .NATURAL && currentAccidentalBeforeEdit == .NONE) {
                        notesForDisplay[editPosition].notes.append((line: line, accidental: accidental))
                }
            }
        }
        else {
            notesForDisplay[editPosition].notes.append((line: line, accidental: accidental))
            notesForDisplay[editPosition].measureLine = nil
            notesForDisplay[editPosition].space = false
        }
        setNeedsDisplay()
    }
    func setNoteHeadForPosition(head: NoteHeadSymbol) {
        if notesForDisplay.count == 0 {
            nextPosition()
        }
        notesForDisplay[editPosition].head = head
    }

    func setTextsForPosition(texts: [String] = []) {
        if notesForDisplay.count == 0 {
            nextPosition()
        }
        notesForDisplay[editPosition].texts = texts
        setNeedsDisplay()
    }
    
    func setNotesForPosition(notes: [(line: Int, accidental: AccidentalSymbol)], head: NoteHeadSymbol = .BLACK, texts: [String] = []) {
        if notesForDisplay.count == 0 {
            nextPosition()
        }
        clearPosition()
        notesForDisplay[editPosition].head = head
        notesForDisplay[editPosition].notes = notes
        notesForDisplay[editPosition].texts = texts
        notesForDisplay[editPosition].measureLine = nil
        notesForDisplay[editPosition].space = false
        nextPosition()
    }
    func setMeasureLineForPosition(style: MeasureLineStyle = .SINGLE, clearLineEnd: Bool = false) {
        if notesForDisplay.count == 0 {
            nextPosition()
        }
        notesForDisplay[editPosition].notes = []
        notesForDisplay[editPosition].texts = []
        notesForDisplay[editPosition].measureLine = (style: style, clearLineEnd: clearLineEnd)
        notesForDisplay[editPosition].space = false
        nextPosition()
        setNeedsDisplay()
    }
    func setSpaceForPosition() {
        if notesForDisplay.count == 0 {
            nextPosition()
        }
        notesForDisplay[editPosition].notes = []
        notesForDisplay[editPosition].texts = []
        notesForDisplay[editPosition].measureLine = nil
        notesForDisplay[editPosition].space = true
        nextPosition()
        setNeedsDisplay()
    }
}

// MARK: Cursor View related

extension ScoreLineView {

    func moveCursor() {
        if showCursor || debugColor {
            let cursorBeginY: CGFloat = yLine0 - noteHeight * 7
            let cursorHeight: CGFloat = noteHeight * 9

            cursorView.fontSize = fontSize
            cursorView.lineWidth = lineWidth
            cursorView.noteHeight = noteHeight
            cursorView.yLine0 = cursorHeight - (noteHeight * 2)

            if editClef || editKeySignature {
                var beginX: CGFloat = 0.0
                var width: CGFloat = self.calcWidthForGlyph(self.scoreClef.glyph) * 1.2
                if editKeySignature {
                    beginX = self.calcWidthForGlyph(scoreClef.glyph) * 1.2
                    width = self.calcWidthForGlyph(AccidentalSymbol.SHARP.glyph) * 7
                }
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.cursorView.frame = CGRectMake(beginX, cursorBeginY, width, cursorHeight)
                    self.cursorView.hidden = false
                    self.cursorView.layoutIfNeeded()
                    self.cursorView.setNeedsDisplay() }, completion: nil)
            }
            else {
                for position in notesForDisplay.indices {
                    if let b = notesForDisplay[position].beginX {
                        if let w = notesForDisplay[position].width {

                            let path = UIBezierPath()
                            path.lineWidth = lineWidth
                            if position == editPosition {
                                var width = max(w, calcWidthForGlyph(NoteHeadSymbol.BLACK.glyph) + calcWidthForGlyph(AccidentalSymbol.DOUBLE_SHARP.glyph))
                                width += calcWidthForGlyph(AccidentalSymbol.DOUBLE_FLAT.glyph)
                                let beginX = b - calcWidthForGlyph(AccidentalSymbol.DOUBLE_FLAT.glyph)
                                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    self.cursorView.frame = CGRectMake(beginX, self.yLine0 - self.noteHeight * 7, width, self.noteHeight * 9)
                                    self.cursorView.hidden = false
                                    self.cursorView.layoutIfNeeded()
                                    self.cursorView.setNeedsDisplay() }, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            self.cursorView.hidden = true
        }
    }

    func showHoverClefOnCursor(clef: ClefSymbol = .G) {
        cursorView.showHoverClef = true
        cursorView.clef = clef
        cursorView.setNeedsDisplay()
    }
    func showHoverKeySignatureOnCursor(key: KeySignature = .NATURAL) {
        cursorView.showHoverKeySignature = true
        cursorView.keySignature = key
        cursorView.clef = scoreClef
        cursorView.setNeedsDisplay()
    }
    func showHoverHeadOnCursorOnLine(line: Int, drewNoteByPress: Bool, accidental: AccidentalSymbol = .NATURAL) {
        cursorView.showHoverHead = true
        cursorView.accidental = accidental
        cursorView.hoverHeadOnLine = line
        cursorView.noteHead = notesForDisplay[editPosition].head
        cursorView.stemDirection = notesForDisplay[editPosition].stemDirection
        cursorView.stemOffsetX = notesForDisplay[editPosition].stemOffsetX
        cursorView.headStyle = drewNoteByPress ? .drew : .draw

        if let _ = notesForDisplay[editPosition].notes.indexOf({ $0.line == line }) {
            if !drewNoteByPress && notesForDisplay[editPosition].notes.count > 1 {
                if accidental == currentAccidentalAtCurrentEditPositionForLine(line) ||
                    (accidental == .NATURAL && currentAccidentalAtCurrentEditPositionForLine(line) == .NONE){
                        cursorView.headStyle = .delete
                }
            }
        }
        cursorView.setNeedsDisplay()
    }
    func hideHoverOnCursor() {
        cursorView.showHoverClef = false
        cursorView.showHoverKeySignature = false
        cursorView.showHoverHead = false
        cursorView.setNeedsDisplay()
    }
}

