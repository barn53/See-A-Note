public enum IntervalModifier {
    case rein, groß, klein, übermäßig, doppeltÜbermäßig, vermindert, doppeltVermindert, tritonus

    public var values: (name: String, semitones: Int) {
        switch self {
        case rein:              return ("rein",                0) // perfect
        case groß:              return ("groß",                0) // major
        case klein:             return ("klein",              -1) // minor
        case übermäßig:         return ("übermäßig",           1) // augmented
        case doppeltÜbermäßig:  return ("doppelt übermäßig",   2) // double augmented
        case vermindert:        return ("vermindert",          100) // -1 bei reinen, -2 bei großen Grundintervallen // dimished
        case doppeltVermindert: return ("doppelt vermindert",  100) // -2 bei reinen, ungültig bei großen Grundintervallen // double dimished
        case tritonus:          return ("tritonus",            100) // +1 bei Quarte, -1 bei Quinte // tritone
        }
    }

    public static func intervalModifierForModifySemitones(semitones: Int, baseModifier: IntervalModifier) -> IntervalModifier? {
        switch baseModifier {
        case .rein:
            switch semitones {
            case 0:
                return .rein
            case -1:
                return .vermindert
            case -2:
                return .doppeltVermindert
            case 1:
                return .übermäßig
            case 2:
                return .doppeltÜbermäßig
            default:
                return nil
            }
        case .groß:
            switch semitones {
            case 0:
                return .groß
            case -1:
                return .klein
            case -2:
                return .vermindert
            case 1:
                return .übermäßig
            case 2:
                return .doppeltÜbermäßig
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
