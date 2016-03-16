public enum Vorzeichen {
    case ohne, be, doppelBe, kreuz, doppelKreuz

    public var values: (name: String, deltaSemitones: Int) {
        switch self {
        case ohne:
            return ("", 0)
        case be:
            return ("♭", -1)
        case doppelBe:
            return ("♭♭", -2) // UTF-8: �
        case kreuz:
            return ("♯", 1)
        case doppelKreuz:
            return ("♯♯", 2)  // UTF-8: �
        }
    }
}

