# Validation and submission checklist

## Verification record

The 20-test suite passed with zero failures, confirmed by the Xcode Test navigator screenshot provided on September 19, 2026. Manual checks remain pending unless recorded below.

| Item | Result |
| --- | --- |
| Revision tested | `6f7943a` |
| Xcode version and build | Xcode 27.0 (`27A266a`) |
| Device / simulator and OS | iPhone 18 Pro simulator, iOS 27.0 |
| Build result | Succeeded |
| XCTest result / failures | 20 passed, 0 failures |
| Manual UI review | ✅ |
| Accessibility review | ✅ |
| Screenshots / video | ✅ |

## Automated tests

Latest recorded results:

| Suite | Passed | Failed |
| --- | --- | --- |
| R4ReportDecoderTests | 10 | 0 |
| ReportViewModelTests | 5 | 0 |
| LiveReportRepositoryTests | 3 | 0 |
| ReportFormattingTests | 2 | 0 |
| Total | 20 | 0 |

Select the shared **YourHealthNS** scheme and a simulator, then choose **Product → Test** (⌘U). Inspect failures in the Test navigator and record the outcome above.

| Suite | Focus |
| --- | --- |
| R4ReportDecoderTests | Captured 17-result report, linked-result order, missing/conflicting subjects, contained scope, interpretations, absent values, restricted statuses, modifiers, malformed resources, empty outcomes |
| ReportViewModelTests | Load deduplication, retry, refresh retention, cancellation, state restoration |
| LiveReportRepositoryTests | GET/Accept contract, content types, HTTP/transport failures, malformed data |
| ReportFormattingTests | Missing values and laboratory date offset |

Tests do not use a global mutable response handler or sleep-based synchronization.

This is an application-hosted unit-test target. Assertions are independent of the live endpoint, but launching the host may initiate the app's normal startup request.

## Manual functional checks

- [x] Fresh launch displays branding and reaches Home.
- [x] Report metadata matches the current live source.
- [x] View report switches tabs; the plain back arrow returns Home.
- [x] Result order/count match DiagnosticReport.result.
- [x] Values and units match the source, including hematocrit supplied as a percentage.
- [x] Refresh works from both tabs without overlapping requests.
- [x] Offline initial failure offers a working retry after reconnection.
- [x] Failed refresh retains existing results and displays an explanatory message.
- [x] App switching covers report content; returning restores the report/tab.

Synthetic unit-test payloads cover edge outcomes the live endpoint may not expose. Do not change production data merely to make a screenshot.

## Layout and accessibility

- [x] Small and large iPhone layouts.
- [x] iPad and landscape layout.
- [x] Large accessibility text sizes without clipped values or actions.
- [x] VoiceOver reading order, action labels, loading state, and result context.




