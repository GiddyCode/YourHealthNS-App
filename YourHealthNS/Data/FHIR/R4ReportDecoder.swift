import Foundation
import FMCore

/// Decodes and maps reports off the main actor.
actor R4ReportDecoder {
    func decode(_ data: Data) throws -> ReportOutcome {
        try Task.checkCancellation()
        do {
            let bundle = try JSONDecoder.fhirModelsReadyDecoder().decode(R4ReportBundle.self, from: data)
            let outcome = try R4ReportMapper().map(bundle)
            try Task.checkCancellation()
            return outcome
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as ReportDataError {
            throw error
        } catch {
            // Decoding errors can contain source data.
            throw ReportDataError.invalidPayload
        }
    }
}
