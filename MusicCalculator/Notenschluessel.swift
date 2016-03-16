enum Notenschlüssel {
    case violin, bass

    var values: (name: String, lineDelta: Int) {
        switch self {
        case .violin:
            return ("Violinschlüssel", 0)
        case .bass:
            return ("Bassschlüssel", 12)
        }
    }
}
