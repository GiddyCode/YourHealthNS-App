# YourHealthNS

YourHealthNS is a SwiftUI app for viewing a laboratory report. It fetches the report from the assessment's FHIR endpoint and displays the report details and linked results across two tabs.

## Features

- Home screen with the report name, status, laboratory, and clinical date.
- Report screen with ordered results, values, units, reference ranges, and interpretation chips.
- Pull-to-refresh on both tabs, with shared loading and report state.
- Retry for failed requests. Existing results stay visible if a refresh fails.
- Branded launch screen and microscope loading animation.
- Privacy cover when the app becomes inactive.
- Dynamic Type support, VoiceOver labels, and layouts for iPhone and iPad.

## App preview
https://github.com/user-attachments/assets/1c3e60ba-d632-401a-a3ca-328156ed7d21

https://github.com/user-attachments/assets/4a7cc22c-2dad-465a-be3b-1ec9acaaadd9

Additional videos and screenshots of loading, privacy, error states, and responsive layouts are in [App screenshots and videos](docs/MEDIA.md).

## Requirements

| Item | Project configuration |
| --- | --- |
| IDE | Xcode 27.0 |
| Deployment target | iOS / iPadOS 17.0 or later |
| Language | Swift, Swift 5 language mode |
| UI | SwiftUI |
| Dependency | Apple FHIRModels 0.9.3, exact Swift Package Manager version |
| Network | HTTPS access to the public report endpoint |

Use a Mac compatible with the selected Xcode release and install an iOS simulator runtime through Xcode if needed. Compiler version and Swift language mode are separate settings.

## Setup

1. Clone or extract the complete repository, including the Xcode project, shared scheme, and package lockfile.
2. Open `YourHealthNS.xcodeproj` in Xcode.
3. Allow Swift Package Manager to resolve FHIRModels. If needed, use **File → Packages → Resolve Package Versions**.
4. Select the **YourHealthNS** scheme and an installed iPhone simulator running iOS 17 or later.
5. Build and run with **Product → Run**.

For a physical device, select your development team under **Signing & Capabilities** and update the bundle identifier if required.

There are no API keys or additional services to configure. The project uses Swift 5 language mode and pins Apple FHIRModels to version 0.9.3 through Swift Package Manager.

If package resolution fails, check your connection and use **File → Packages → Resolve Package Versions**. If no simulator is available, install a compatible runtime in Xcode.

## Relevant Assumptions

- The assessment endpoint is publicly accessible and does not require authentication.
The assessment scope is a read-only view of the supplied report, so patient selection, report history, editing, and local persistence are outside the app's scope.
- The response is a FHIR R4 Bundle containing no more than one DiagnosticReport. 
- Observation and performer references are resolved from resources included in the response; the app does not request missing linked resources separately.
- Values, units, reference ranges, and interpretations from the source are treated as authoritative. The app does not calculate clinical interpretations or convert units.

## Architecture

I used **MVVM** with a **Clean Architecture** folder structure to separate the UI, report models, and data handling.

| Layer | Responsibility |
| --- | --- |
| App | Creates dependencies and handles tabs, launch presentation, and scene state. |
| Presentation | Feature views, report state, view model, and display formatting. |
| Domain | Report and result models, interpretation types, and the repository protocol. |
| Data | Network requests, FHIR decoding, reference resolution, and mapping. |
| DesignSystem | Shared colors, spacing, surfaces, and branding. |

Home and Report share one `ReportViewModel` because they display the same report. This keeps both tabs in sync and prevents duplicate requests. The view model runs on the MainActor; the repository and decoder use actors.

Dependencies are passed through initializers. The view model depends on `ReportRepository`, so tests can replace the network implementation without changing the presentation code. FHIR resources are mapped to domain values before they reach the UI.

I kept the structure small: a separate use-case layer or dependency-injection framework would not add much for a single report-fetching operation.

```text
YourHealthNS/
  App/
  Domain/
    Models/
    Repositories/
  Data/
    FHIR/
    Repositories/
  Presentation/
    Features/
      Home/View/
      Report/View/
      Report/ViewModel/
    Formatting/
    Shared/
  DesignSystem/
  Assets.xcassets/
  LaunchScreen.storyboard
YourHealthNSTests/
  Fixtures/
docs/
```

The [architecture document](docs/ARCHITECTURE.md) includes the dependency diagram, request flow, and state transitions.

## API and FHIR parsing

The app retrieves the report with a GET request to:

```text
https://build.fhir.org/diagnosticreport-example.json
```

The endpoint is configured in `YourHealthNS/App/ContentView.swift`. The repository checks the HTTP status, content type, and response body before decoding.

Apple FHIRModels supplies the R4 models and FHIR-aware JSON decoder. The data layer reads the collection Bundle, finds its DiagnosticReport, and resolves the referenced Observations and performer information.

### Data-handling decisions

- Results follow `DiagnosticReport.result` order, not Bundle entry order.
- Missing or ambiguous references remain visible as unavailable results.
- References are resolved within the response. The app does not make additional requests for unresolved resources.
- Conflicting subject references suppress the linked measurement. Contained references are checked within their resource scope.
- Values, units, comparators, reference ranges, and source interpretations are retained. No unit conversions or clinical interpretations are calculated.
- Interpretation chips use the supplied codes. A result is not labelled Normal just because its value falls inside a reference range.
- The report date comes from `effectiveDateTime` or `effectivePeriod`, not the issued timestamp.
- Restricted statuses and unsupported result structures display an unavailable state rather than a potentially misleading measurement.

## Tests and validation

The current suite has **20 passing tests and zero failures**.

| Suite | Tests |
| --- | --- |
| FHIR decoding and mapping | 10 |
| View-model state and request lifecycle | 5 |
| Network response and error handling | 3 |
| Display formatting | 2 |

Coverage includes the captured 17-result report, linked-result order, contained subject references, missing values, malformed data, retry, refresh retention, concurrent-request prevention, and cancellation.

To run the tests, select the **YourHealthNS** scheme and an iOS simulator, then press **⌘U**.

Tests use a captured fixture, synthetic payloads, repository doubles, and stubbed HTTP responses. Their assertions do not depend on the live endpoint. The target is application-hosted, so app startup may still make its own report request.

The recorded validation used Xcode 27.0 with an iPhone 18 Pro simulator running iOS 27.0. Manual checks also cover navigation, refresh and retry, the privacy cover, iPhone/iPad layouts, large text, and VoiceOver. Full results are in [testing and validation](docs/VALIDATION.md).

## Privacy and accessibility

A privacy cover hides report content while the scene is inactive. Check [Screenshots and videos](docs/MEDIA.md) for demo.

Report data stays in memory for the session. The network session is ephemeral, with URL caching, cookie storage, and credential storage disabled. There is no analytics or report persistence.

The UI uses descriptive accessibility labels, scalable text, and text-based interpretation chips so meaning does not depend on color alone.

## Further documentation

- [Architecture and data flow](docs/ARCHITECTURE.md)
- [Validation results](docs/VALIDATION.md)
- [Screenshots and videos](docs/MEDIA.md)
