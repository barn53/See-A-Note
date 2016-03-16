// Meine Definition:        --12--
// ---------------------10-----------------
// ------------------8---------------------
// ---------------6------------------------
// ------------4---------------------------
// ---------2------------------------------
//     --0--   <-- Linie 0 Bezugspunkt (Violinschlüssel c')

public struct Note {
    public var grundTon = Grundton.c
    public var vorzeichen = Vorzeichen.ohne
    public var oktave = Oktave.eingestrichen

    public init() {

    }

    public var line: Int {
        return grundTon.values.baseLine + oktave.values.lineDelta
    }

    public var semitones: Int {
        return grundTon.values.semitones + vorzeichen.values.deltaSemitones + (oktave.values.ordinal * 12)
    }

    public var name: String {
        return oktave.values.upper
            ?
                oktave.values.postPräfix + grundTon.values.name.uppercaseString + vorzeichen.values.name
            :
            grundTon.values.name + vorzeichen.values.name + oktave.values.postPräfix
    }

    public var describe: String {
        return "\(name) - Halbtöne: \(semitones), Linie: \(line)"
    }
}
