struct ResultInterpretation: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case normal, high, low, criticalHigh, criticalLow, abnormal, unknown
    }

    struct Coding: Equatable, Sendable {
        let system: String?
        let code: String?
        let display: String?
    }

    let kind: Kind
    let text: String?
    let codings: [Coding]
}
