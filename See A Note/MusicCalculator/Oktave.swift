public enum Oktave {
    case subsubkontra, subkontra, kontra, groß, klein,
    eingestrichen, zweigestrichen, dreigestrichen, viergestrichen, fünfgestrichen
    // die eingestrichene ist das c' auf der ersten Hilfslinie unten im Violinschlüssel

    public var values: (lineDelta: Int, ordinal: Int, upper: Bool, postPräfix: String) {
        switch self {
        case .subsubkontra:
            return (-35, -5, true, ",,,")
        case .subkontra:
            return (-28, -4, true, ",,")
        case .kontra:
            return (-21, -3, true, ",")
        case .groß:
            return (-14, -2, true, "")
        case .klein:
            return (-7, -1, false, "")
        case .eingestrichen:
            return (0, 0, false, "'")
        case .zweigestrichen:
            return (7, 1, false, "''")
        case .dreigestrichen:
            return (14, 2, false, "'''")
        case .viergestrichen:
            return (21, 3, false, "''''")
        case .fünfgestrichen:
            return (28, 4, false, "'''''")
        }
    }
}

