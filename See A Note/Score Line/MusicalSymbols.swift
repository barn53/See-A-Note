//
//  MusicalSymbols.swift
//  See A Note
//
//  Created by Gerd Müller on 01.09.15.
//  Copyright © 2015 Gerd Müller. All rights reserved.
//

import UIKit

// http://www.smufl.org/files/smufl-1.18.pdf
// http://www.sengpielaudio.com/Musikbegriffe.htm

enum ClefSymbol {
    case C, F, G

    // unicode characters from BravuraText
    var glyph: NSString {
        switch self {
        case .C: return "\u{e05c}"
        case .F: return "\u{e062}"
        case .G: return "\u{e050}"
        }
    }
    var lineDeltaKeySignatureToGClef: Int {
        switch self {
        case .C: return -1
        case .F: return -2
        case .G: return 0
        }
    }
    var lineDeltaTransposeToGClef: Int {
        switch self {
        case .C: return -6
        case .F: return -12
        case .G: return 0
        }
    }
    var previous: ClefSymbol {
        switch self {
        case .C: return .G
        case .F: return .C
        case .G: return .F
        }
    }
    var next: ClefSymbol {
        switch self {
        case .C: return .F
        case .F: return .G
        case .G: return .C
        }
    }
}

enum RestSymbol {
    case EIGHTH, QUARTER, HALF, WHOLE

    // unicode characters from BravuraText
    var glyph: NSString {
        switch self {
        case .EIGHTH: return "\u{e4e6}"
        case .QUARTER: return "\u{e4e5}"
        case .HALF: return "\u{e4e4}"
        case .WHOLE: return "\u{e4e3}"
        }
    }
}

enum MeasureLineStyle {
    case NONE // is to clear accidentals
    case SINGLE, DOUBLE, END, VIEW_END
}

enum NoteHeadSymbol {
    case BLACK, HALF, WHOLE, BREVE, BREVE_SQUARE,
        LEGER_LINE, STAFF_5_LINES

    // unicode characters from BravuraText
    var glyph: NSString {
        switch self {
        case .BLACK: return "\u{e0a4}"
        case .HALF: return "\u{e0a3}"
        case .WHOLE: return "\u{e0a2}"
        case .BREVE: return "\u{e0a0}"
        case .BREVE_SQUARE: return "\u{e0a1}"
        case .LEGER_LINE: return "\u{e022}"
        case .STAFF_5_LINES: return "\u{e014}"
        }
    }
}

enum AccidentalSymbol {
    case NONE, NATURAL, FLAT, DOUBLE_FLAT, SHARP, DOUBLE_SHARP

    // unicode characters from BravuraText
    var glyph: NSString {
        switch self {
        case .NONE: return ""
        case .NATURAL: return "\u{e261}"
        case .FLAT: return "\u{e260}"
        case .DOUBLE_FLAT: return "\u{e264}"
        case .SHARP: return "\u{e262}"
        case .DOUBLE_SHARP: return "\u{e263}"
        }
    }
    var previous: AccidentalSymbol {
        switch self {
        case .NONE: return .FLAT
        case .NATURAL: return .FLAT
        case .FLAT: return .DOUBLE_FLAT
        case .DOUBLE_FLAT: return .DOUBLE_SHARP
        case .SHARP: return .NATURAL
        case .DOUBLE_SHARP: return .SHARP
        }
    }
    var next: AccidentalSymbol {
        switch self {
        case .NONE: return .SHARP
        case .NATURAL: return .SHARP
        case .FLAT: return .NATURAL
        case .DOUBLE_FLAT: return .FLAT
        case .SHARP: return .DOUBLE_SHARP
        case .DOUBLE_SHARP: return .DOUBLE_FLAT
        }
    }
}

enum KeySignature {
    case NATURAL,
    FLAT_1, FLAT_2, FLAT_3, FLAT_4, FLAT_5, FLAT_6, FLAT_7,
    SHARP_1,SHARP_2,SHARP_3,SHARP_4,SHARP_5,SHARP_6, SHARP_7

    var previous: KeySignature {
        switch self {
        case .NATURAL: return .SHARP_7
        case .FLAT_1: return  .NATURAL
        case .FLAT_2: return  .FLAT_1
        case .FLAT_3: return  .FLAT_2
        case .FLAT_4: return  .FLAT_3
        case .FLAT_5: return  .FLAT_4
        case .FLAT_6: return  .FLAT_5
        case .FLAT_7: return  .FLAT_6
        case .SHARP_1: return .FLAT_7
        case .SHARP_2: return .SHARP_1
        case .SHARP_3: return .SHARP_2
        case .SHARP_4: return .SHARP_3
        case .SHARP_5: return .SHARP_4
        case .SHARP_6: return .SHARP_5
        case .SHARP_7: return .SHARP_6
        }
    }

    var next: KeySignature {
        switch self {
        case .NATURAL: return .FLAT_1
        case .FLAT_1: return  .FLAT_2
        case .FLAT_2: return  .FLAT_3
        case .FLAT_3: return  .FLAT_4
        case .FLAT_4: return  .FLAT_5
        case .FLAT_5: return  .FLAT_6
        case .FLAT_6: return  .FLAT_7
        case .FLAT_7: return  .SHARP_1
        case .SHARP_1: return .SHARP_2
        case .SHARP_2: return .SHARP_3
        case .SHARP_3: return .SHARP_4
        case .SHARP_4: return .SHARP_5
        case .SHARP_5: return .SHARP_6
        case .SHARP_6: return .SHARP_7
        case .SHARP_7: return .NATURAL
        }
    }

    var numberOfAccidentals: Int {
        switch self {
        case .NATURAL: return 0
        case .FLAT_1, .SHARP_1: return 1
        case .FLAT_2, .SHARP_2: return 2
        case .FLAT_3, .SHARP_3: return 3
        case .FLAT_4, .SHARP_4: return 4
        case .FLAT_5, .SHARP_5: return 5
        case .FLAT_6, .SHARP_6: return 6
        case .FLAT_7, .SHARP_7: return 7
        }
    }

    var accidental: AccidentalSymbol {
        switch self {
        case .NATURAL: return .NATURAL
        case FLAT_1, FLAT_2, FLAT_3, FLAT_4, FLAT_5, FLAT_6, FLAT_7: return .FLAT
        case SHARP_1, SHARP_2, SHARP_3, SHARP_4, SHARP_5, SHARP_6, SHARP_7: return .SHARP
        }
    }

    var lines: [Int] {
        // lines for the accidentals in relation to G clef
        switch self {
        case NATURAL: return []
        case FLAT_1: return [6]
        case FLAT_2: return [6, 9]
        case FLAT_3: return [6, 9, 5]
        case FLAT_4: return [6, 9, 5, 8]
        case FLAT_5: return [6, 9, 5, 8, 4]
        case FLAT_6: return [6, 9, 5, 8, 4, 7]
        case FLAT_7: return [6, 9, 5, 8, 4, 7, 3]
        case SHARP_1: return [10]
        case SHARP_2: return [10, 7]
        case SHARP_3: return [10, 7, 11]
        case SHARP_4: return [10, 7, 11, 8]
        case SHARP_5: return [10, 7, 11, 8, 5]
        case SHARP_6: return [10, 7, 11, 8, 5, 9]
        case SHARP_7: return [10, 7, 11, 8, 5, 9, 6]
        }
    }
}
