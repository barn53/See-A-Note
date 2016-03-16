public enum IntervalType {
    case Prim, Second, Terz, Quarte, Quinte, Sexte, Septime, Oktave

    public var values: (name: String, lines: Int, semitones: Int, baseModifier: IntervalModifier) {
        switch self {
        case Prim:     return ("Prim",   0, 0,  .rein)  // unison
        case Second:   return ("Second", 1, 2,  .groß)  // 2nd
        case Terz:     return ("Terz",   2, 4,  .groß)  // 3rd
        case Quarte:   return ("Quarte", 3, 5,  .rein)  // 4th
        case Quinte:   return ("Quinte", 4, 7,  .rein)  // 5th
        case Sexte:    return ("Sexte",  5, 9,  .groß)  // 6th
        case Septime:  return ("Septe",  6, 11, .groß)  // 7th
        case Oktave:   return ("Oktave", 7, 12, .rein)  // octave
        }
    }

    public static func intervalTypeForDeltaLines(lines: Int) -> IntervalType? {
        switch lines {
        case 0:
            return .Prim
        case 1:
            return .Second
        case 2:
            return .Terz
        case 3:
            return .Quarte
        case 4:
            return .Quinte
        case 5:
            return .Sexte
        case 6:
            return .Septime
        case 7:
            return .Oktave
        default:
            return nil
        }
    }
}
