public enum Grundton {
    case c, d, e, f, g, a, h

    public var values: (name: String, baseLine: Int, semitones: Int) {
        switch self {
        case c:
            return ("c", 0, 0)
        case d:
            return ("d", 1, 2)
        case e:
            return ("e", 2, 4)
        case f:
            return ("f", 3, 5)
        case g:
            return ("g", 4, 7)
        case a:
            return ("a", 5, 9)
        case h:
            return ("h", 6, 11)
        }
    }
}
