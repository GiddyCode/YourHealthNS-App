# YourHealthNS

A native iOS assessment app for presenting a hematology diagnostic report through exactly two primary tabs: **Home** and **Report**.

## Implementation status

Development is in progress. The owner committed the default SwiftUI application as **`bf0f77f` — Initial Commit**. The next working increment adds the branded Home/Report shell, the supplied image assets, semantic styling, accessible empty states, and an iOS 17 minimum deployment target. Report retrieval and clinical mapping are not implemented in this increment.

This README is a local working document. Its changes must remain uncommitted until a dedicated documentation commit after the final implementation commit. Every commit, including that documentation commit, requires the owner's approval.

The owner is running the app in Xcode and has taken over testing for every commit. Do not build, test, launch, stop, or otherwise interact with the app, Xcode, or its simulator unless explicitly requested. Subsequent verification status records owner-reported results separately from earlier checks performed during the baseline setup.

The original assessment and private correspondence are intentionally excluded from this repository. The employer assessment and the supplementary implementation brief were supplied for local review.

## Implementation and verification plan

Each milestone will be implemented and presented for owner testing and approval **before its local commit**. Publishing and submission require separate authorization. The original repository baseline is `4b2b704`; the owner committed the default project as `bf0f77f` on `main`. Current implementation continues on that branch.

| Milestone / proposed commit purpose | Acceptance criteria | Verification gate |
| --- | --- | --- |
| 0. `bf0f77f` — Initial Commit | Default Xcode 27 SwiftUI app, no storage or testing targets; no branding or report features | Baseline build and launch passed; committed by owner; README changes excluded |
| 1. `feat(ui): add branded Home and Report shell` | Exactly two native tabs; Home action selects Report; supplied brand assets; semantic light/dark styling; empty state; iOS 17 minimum | Implementation prepared; owner build/navigation/appearance checks pending |
| 2. `ci: add simulator build workflow` | Officially verified runner/toolchain; unsigned build; pinned automation | Workflow review and matching local command; remote run reported separately |
| 3. `feat(fhir): map R4 report and referenced observations` | Domain contracts; evaluated R4 dependency; immutable public fixture; scoped reference resolver and clinical mapping | Captured-payload and edge-case mapping tests; application build |
| 4. `feat(networking): fetch diagnostic report through injected transport` | Required live GET; ephemeral session; explicit errors; no fixture fallback | Isolated transport tests covering success, failure, and cancellation |
| 5. `feat(report): manage loading and refresh state` | Shared main-actor view model; coherent states; cancellation/race policy; loading threshold | Deterministic state, overlap, refresh, and lifetime tests |
| 6. `feat(ui): compose branded launch and report experience` | One-time splash; genuine loading; complete Home/Report; partial/recovery states | UI tests, actual simulator screenshots, accessibility and design critique |
| 7. `feat(privacy): protect report content in app switcher previews` | Background cover; verified in-memory data and sanitized diagnostics | Lifecycle tests, transport configuration review, manual simulator checks |
| 8. `docs: complete reviewer setup and verification guide` | Actual evidence, tradeoffs, architecture, commit record, reproducible clean archive | Full relevant test suite, final source/privacy review, archive inspection |

Milestones may be split when a finding warrants its own behavioral fix. Tests land with the behavior they protect, but execution now belongs to the owner. The earlier uncommitted foundation is preserved in `.local-work/deferred-foundation`; only selected application components have been adapted into the native project. Its old project generator and Xcode project are not used.

### Current increment: branded shell

- `ContentView` hosts `AppTabs`, which owns tab selection. Each primary tab has its own native navigation stack; the Home button changes selection without pushing a duplicate report screen.
- `Features/Home` and `Features/Report` define the two screen layouts. The only displayed report state is **No report loaded**. There is no request, fake measurement, loading spinner, retry button, or claim that data has been retrieved.
- `DesignSystem` contains the small semantic palette, layout tokens, surface/button styles, wordmark, empty state, and decorative background. Light portrait layouts use the supplied wave image; wide and dark layouts use subdued native wave shapes to avoid excessive cropping.
- Body text uses scalable system fonts and scrollable containers. Decorative illustrations are hidden from accessibility; headings and the wordmark retain semantic labels. Increased Contrast strengthens borders. The shell contains no animation, so there is no motion to suppress yet.
- Original image files are included unchanged. The default AppIcon and generated native launch screen remain unchanged; custom launch/splash/loading behavior belongs to the later launch milestone.
- The owner's existing edit to the `ContentView.swift` header is preserved.
- Xcode normalized the project file's formatting while it was open; those changes are preserved. The intended configuration change in this increment is the iOS 17 deployment target in Debug and Release.

Owner checks for this increment: confirm both tabs appear; use **View report** and return to Home; inspect light/dark appearance, larger accessibility text, and an iPad or landscape layout. No build, test, launch, or preview rendering has been performed for this increment. All changes remain uncommitted, and README must be excluded when committing.

## Requirements checklist

| Requirement | Planned implementation | Evidence required before completion |
| --- | --- | --- |
| Native Swift, Home and Report tabs | SwiftUI app, shared state, native tab navigation | Build and navigation UI test |
| GET the prescribed endpoint | Injected HTTP client using `https://build.fhir.org/diagnosticreport-example.json` | Live shape inspection; offline transport tests |
| FHIR R4 semantics | Isolated R4 decoder, resolver, mapper, immutable domain values | Fixture provenance and mapping tests for every linked result |
| Correct clinical fields | Source labels, performer, effective date, ordered values/units/ranges/status | Explicit fallback policies and edge-case assertions |
| Reliable presentation | Combine observation with async/await transport; refresh retaining content | Cancellation, duplicate-load, and late-response tests |
| Branded, accessible UI | Shared semantic tokens and components; adaptive screens | Real screenshots, dark appearance, Dynamic Type, Reduce Motion checks |
| Privacy | Memory-only reports, ephemeral transport, lifecycle cover | Configuration tests and background review |
| Current stable Xcode | Verify Apple's current release separately from local installation | Dated official source and exact installed version |
| Reproducible submission | Checked-in project, shared scheme, dependency lock if needed, README, CI | Clean build/test commands and reproducible archive |

## Design direction

The visual reference establishes a calm blue-white canvas, Nova Scotia Health wordmark, cyan/green waves, and a clear progression from launch to Home to the report. Preserve supplied artwork at its original aspect ratio and color. Use native scalable typography, deep navy primary text, generous screen margins, white surfaces, and restrained borders. The microscope is a supporting illustration; the primary Home action selects the existing Report tab.

Use a compact spacing rhythm (4, 8, 12, 16, 24, 32 points), 20-point screen margins, 20-point surface corners, and a maximum 680-point reading width. Dark appearance uses navy surfaces and lighter accessible controls; the wordmark retains a light backing for legibility. Clinical status colors will be separate from brand accents and always accompanied by sourced text.

The original transparent wordmark, microscope, and wave background are included in the active asset catalog without changing their bytes. The microscope has a baked white background and therefore sits on a white tile. The transparent wordmark is only 209 × 80 pixels; enlarging it can soften its edges. The larger supplied logo has a baked white background and is not included in the runtime assets.

Exact representative opaque sRGB pixels sampled from the wordmark are `BrandBlue #1B5A7C`, `BrandCyan #00ABC7`, `BrandGreen #6EBE4A`, and `BrandGray #8C8B8E`. The action color `#0068E4` is sampled from the microscope. Cyan/green are decorative accents; body text uses independently chosen, higher-contrast semantic colors.

Calculated contrast against the actual surface colors: primary/secondary text **16.97:1 / 6.21:1** in light appearance and **14.15:1 / 8.87:1** in dark appearance. Button labels are **5.12:1** in light and **9.65:1** in dark. Increased Contrast strengthens grouping borders. These numerical checks do not substitute for the planned simulator accessibility review.

## Environment inspected

- macOS 26.6 (25G5028f).
- **Xcode 27.0 (27A266a)**, verified after installation and selected at `/Applications/Xcode.app/Contents/Developer`.
- **Apple Swift 6.4**; installed iOS SDK **27.0**. The default template uses Swift 5 language mode with approachable concurrency and main-actor default isolation; a later architecture milestone will make deliberate concurrency choices.
- First-launch setup check passed. Available simulator runtimes include **iOS 27.0 (24A434)** and iOS 26.0.1 (23A8464).
- Minimum deployment target: **iOS 17.0** in the current branded-shell increment, lowered from the default commit's iOS 27 target. This is independent of the Xcode 27 build tool and SDK version. Minimum-version execution remains unverified.

As of **September 18, 2026**, Apple's [release listing](https://developer.apple.com/news/releases/) and [system requirements](https://developer.apple.com/xcode/system-requirements) identify **Xcode 27 (27A266a), Swift 6.4**, as the latest stable release. The local installation now matches that release.

The earlier foundation was superseded before any commit; its first build had found a missing app-icon set. The native project retains the standard empty AppIcon and has no version-pinned framework reference. Its AccentColor now supplies the semantic action color. The default baseline built and launched successfully; the subsequent branded-shell changes have not been built or run by the assistant, and no CI run has occurred.

## Executed baseline verification — September 18, 2026

- `xcodebuild -version`: Xcode 27.0, build 27A266a.
- `swift --version`: Apple Swift 6.4.
- `xcrun --sdk iphonesimulator --show-sdk-version`: 27.0.
- `xcodebuild -checkFirstLaunchStatus`: succeeded.
- `plutil -lint YourHealthNS.xcodeproj/project.pbxproj`: passed.
- Default-project Debug build on iPhone 18 Pro / iOS 27.0: succeeded, with **0 errors and 0 warnings** in the result bundle.
- Installed and launched with `simctl`; manually inspected the real simulator screenshot showing the default globe and “Hello, world!” view.
- Before owner commit: `git diff --cached --check` passed for the eight default-project files, with README excluded. The owner subsequently committed that baseline as `bf0f77f`.
- No automated tests ran: the default template intentionally has no test target. Tests will accompany application behavior in subsequent milestones.

Exact verified build command:

```sh
xcodebuild -quiet -project YourHealthNS.xcodeproj -scheme YourHealthNS \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=F3D56C79-E3A7-4DC7-97BF-FFB7757CA7CD' \
  -derivedDataPath .build/DefaultBaseline \
  -resultBundlePath .build/DefaultBaseline-Verified.xcresult \
  CODE_SIGNING_ALLOWED=NO build
```

The result bundle and `.build/DefaultBaseline-running.png` are local, ignored verification artifacts. Use a new result-bundle path when repeating the command because Xcode will not overwrite an existing bundle. The destination UUID is specific to this development machine.

## Open and build

Open `YourHealthNS.xcodeproj`, choose the **YourHealthNS** scheme and an installed iOS simulator compatible with the minimum target, then Run. Simulator builds do not require a paid developer account. The current project has no third-party dependencies or test targets; meaningful tests will be introduced with the behavior they protect. The commands below are provided for the owner and have not been executed for the branded-shell increment.

```sh
xcodebuild -project YourHealthNS.xcodeproj -scheme YourHealthNS \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/DerivedData CODE_SIGNING_ALLOWED=NO build

xcrun simctl list devices available
```

The native project is sufficient to open and build. It uses Xcode's synchronized source folder, so application source and resource membership follows the `YourHealthNS` directory. There is no project-generator dependency in the first commit.
