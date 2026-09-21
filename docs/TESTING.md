# SecureGuard — Test Plan and Results

Version 1.0.0 • Flutter 3.47.5 / Dart 3.13.4

---

## 1. Testing Approach

SecureGuard was tested at three levels:

| Level | What it covers | How it is run |
|---|---|---|
| **Unit tests** | Validation rules, date/time formatting, the SOS state machine, contact management and location sharing — all without a user interface. | `flutter test` |
| **Widget tests** | Real screens rendered in a test environment, driven the way a user would drive them: typing, tapping, holding the SOS button, scrolling. | `flutter test` |
| **Manual testing** | The complete application running in a browser at phone size, exercised by hand against the test cases in §4. | Manual, against a release web build |

Static analysis (`flutter analyze`) runs over the whole project with the
`flutter_lints` rule set and is expected to report no issues at all.

---

## 2. Automated Test Results

```
$ flutter analyze
Analyzing secureguard-mobile-app...
No issues found!

$ flutter test
00:13 +79: All tests passed!
```

**79 automated tests, all passing. Zero analyzer issues.**

| Test suite | File | Tests | Status |
|---|---|---:|---|
| Form validation rules | `test/validators_test.dart` | 12 | ✅ Pass |
| Date, time and duration formatting | `test/formatters_test.dart` | 12 | ✅ Pass |
| Trusted contact management | `test/contacts_provider_test.dart` | 11 | ✅ Pass |
| Authentication service | `test/auth_service_test.dart` | 10 | ✅ Pass |
| SOS flow, history and location sharing | `test/emergency_flow_test.dart` | 12 | ✅ Pass |
| Screens and user interactions | `test/widget_flow_test.dart` | 22 | ✅ Pass |
| **Total** | | **79** | **✅ All pass** |

The SOS tests use `fake_async` so the three-second hold, the five-second
countdown and the per-contact dispatch delays run instantly instead of making
the suite wait in real time.

### A note on widget-test layout warnings

`flutter test` renders text with a placeholder font in which every character
occupies a full em square, so a label such as *"Forgot password?"* measures
roughly twice its real width. Rows that fit comfortably on a device therefore
report `RenderFlex overflowed` in the test environment only. These reports are
filtered out in `test/helpers/test_app.dart`, and layout is instead verified
against a **real browser rendering at 390 × 844** — the screenshots in
`docs/screenshots/` are that verification. This approach found and fixed a
genuine layout defect on the splash screen (the brand gradient was sizing to
its content instead of filling the screen), which the widget tests could not
have detected.

---

## 3. Test Coverage by Feature

| Feature area | Automated | Manual | Notes |
|---|:--:|:--:|---|
| Splash and start-up routing | ✅ | ✅ | Including first-launch routing to onboarding |
| Onboarding | ✅ | ✅ | All three pages, Next, Skip, Get Started |
| Login | ✅ | ✅ | Demo account, unknown account, validation |
| Registration | ✅ | ✅ | All fields, strength meter, mismatch |
| Password reset | — | ✅ | Simulated flow |
| Dashboard | ✅ | ✅ | Status card, SOS panel, quick actions |
| SOS activation | ✅ | ✅ | Hold, countdown, dispatch, active state |
| SOS cancellation | ✅ | ✅ | Recorded as cancelled, nobody notified |
| SOS guard (no contacts) | ✅ | ✅ | Blocked with an explanatory dialog |
| Trusted contacts | ✅ | ✅ | Add, edit, delete, primary, duplicates |
| Location sharing | ✅ | ✅ | Start, stop, permission withdrawal |
| Emergency services | ✅ | ✅ | Categories, call confirmation, demo dialog |
| Safety tips | ✅ | ✅ | Five tabs, expandable cards |
| Emergency history | ✅ | ✅ | Recording, filtering, detail, delete |
| Notifications | ✅ | ✅ | Generation, unread count, dismiss |
| Settings | ✅ | ✅ | All toggles, countdown, language |
| Dark mode | ✅ | ✅ | Theme switch and contrast |
| Logout | — | ✅ | Confirmation, return to login |
| Persistence | — | ✅ | Data survives a reload |

---

## 4. Test Cases and Results

Every case below states **how** it was verified, so the evidence behind each
result is traceable:

- **Automated** — an automated test asserts this behaviour; the suite is named.
- **Manual** — executed by hand against a release web build running in Chromium
  at 390 × 844, and confirmed by a captured screenshot.

### 4.1 Authentication

| ID | Test case | Expected result | Actual result | Verified by | Status |
|---|---|---|---|---|---|
| T-01 | Login with the demo account | Signs in as Anisa Abdi and opens the dashboard | Dashboard opened, greeting "Anisa", confirmation "Welcome back, Anisa." | Manual + `widget_flow_test` | ✅ Pass |
| T-02 | Login with empty fields | A message under each field | *"Please enter your email address."* and *"Please enter your password."* | Automated — `widget_flow_test` | ✅ Pass |
| T-03 | Login with an invalid email | Email format rejected | *"Please enter a valid email address."* | Automated — `widget_flow_test`, `validators_test` | ✅ Pass |
| T-04 | Login with an unknown account | Explained, not a silent failure | Banner *"Could not sign in"* with an explanation | Automated — `widget_flow_test` | ✅ Pass |
| T-05 | Demo credentials button | Fills in the demonstration account | Both fields populated | Automated — `widget_flow_test` | ✅ Pass |
| T-06 | Password visibility toggle | Password can be shown and hidden | Field toggled between masked and visible | Manual | ✅ Pass |
| T-07 | Remember me across a restart | Session restored without signing in again | After a full page reload the app opened straight on the dashboard | Manual | ✅ Pass |
| T-08 | Registration validation | A message under every required field | Four messages: name, email, phone, password | Automated — `widget_flow_test` | ✅ Pass |
| T-09 | Password mismatch | Rejected before submission | *"Passwords do not match."* | Automated — `widget_flow_test`, `validators_test` | ✅ Pass |
| T-10 | Weak password rejected | Minimum strength enforced | Passwords under 8 characters, or without a letter or a number, rejected | Automated — `validators_test` | ✅ Pass |
| T-11 | Duplicate account email | Cannot register the same email twice | Registration refused: *"An account already exists for that email address."* | Automated — `auth_service_test` | ✅ Pass |
| T-11a | Wrong password on a known account | Told the password is wrong, not that the account is missing | *"Incorrect password. Please try again."* | Automated — `auth_service_test` | ✅ Pass |
| T-11b | Email matching ignores case and spacing | Sign-in still succeeds | `  ANISA@Example.com  ` signed in successfully | Automated — `auth_service_test` | ✅ Pass |
| T-11c | Change password | New password works, old one does not | Account signed in with the new password | Automated — `auth_service_test` | ✅ Pass |

### 4.2 Trusted contacts

| ID | Test case | Expected result | Actual result | Verified by | Status |
|---|---|---|---|---|---|
| T-12 | View contacts | Three demo contacts, one marked Primary | Halima Abdi (Primary), Yusuf Abdi, Sagal Mohamed | Manual + `widget_flow_test` | ✅ Pass |
| T-13 | Primary contact listed first | Primary always at the top | Halima Abdi first in every listing | Automated — `contacts_provider_test` | ✅ Pass |
| T-14 | Add a contact | Contact added and counted | Count went from 3 to 4; the new contact appeared | Automated — `widget_flow_test`, `contacts_provider_test` | ✅ Pass |
| T-15 | Add with an empty name | Rejected with a clear message | *"Please enter the contact's name."* | Automated — `validators_test` | ✅ Pass |
| T-16 | Add with an invalid phone | Rejected with an example | *"Enter a valid phone number, e.g. +252 61 234 5678."* | Automated — `validators_test` | ✅ Pass |
| T-17 | Add a duplicate number | Rejected | *"Another trusted contact already uses this number."* | Automated — `widget_flow_test`, `contacts_provider_test` | ✅ Pass |
| T-18 | Edit a contact | Details change, identity preserved | Name, relationship and phone updated; count unchanged | Automated — `contacts_provider_test` | ✅ Pass |
| T-19 | Delete asks for confirmation | A confirmation dialog first | Dialog *"Delete Yusuf Abdi?"* with Cancel and Delete | Manual | ✅ Pass |
| T-20 | Cancel a deletion | Contact remains | Contact still listed after Cancel | Manual | ✅ Pass |
| T-21 | Set a new primary | Exactly one primary at a time | New primary set; previous flag cleared | Automated — `contacts_provider_test` | ✅ Pass |
| T-22 | Delete the primary contact | Another contact is promoted | The next contact became Primary automatically | Automated — `contacts_provider_test` | ✅ Pass |
| T-23 | Delete every contact | Empty state with a call to action | Empty state shown; `primaryContact` became null | Automated — `contacts_provider_test` | ✅ Pass |

### 4.3 SOS emergency flow

| ID | Test case | Expected result | Actual result | Verified by | Status |
|---|---|---|---|---|---|
| T-24 | Short press does nothing | No alert starts | Ring animated back to empty; state stayed idle | Manual | ✅ Pass |
| T-25 | Hold activates the countdown | Countdown screen appears | *"Emergency Alert Activating…"* with a live count | Automated — `widget_flow_test`; Manual | ✅ Pass |
| T-26 | Countdown lists who will be alerted | All contacts shown, primary marked | Three contacts listed, Halima Abdi starred | Manual | ✅ Pass |
| T-27 | Cancel during the countdown | Alert stops; nobody notified | State returned to idle with zero contacts notified | Automated — `emergency_flow_test`, `widget_flow_test` | ✅ Pass |
| T-28 | Cancellation is logged | Recorded as Cancelled | History gained an SOS Alert event with status Cancelled and no contacts | Automated — `emergency_flow_test` | ✅ Pass |
| T-29 | Countdown completes | Contacts notified, then the active view | All 3 notified in turn; *"Emergency Alert Sent"* displayed | Automated — `emergency_flow_test`, `widget_flow_test`; Manual | ✅ Pass |
| T-30 | Primary contact notified first | Ordered dispatch | Halima Abdi was the first notification delivered | Automated — `emergency_flow_test` | ✅ Pass |
| T-31 | Active alert details | Time, duration, location, contacts, sharing | All present; duration counted up live; 3/3 notified; sharing Live | Manual | ✅ Pass |
| T-32 | Location sharing starts with the alert | Sharing begins automatically | `isSharing` became true as the alert activated | Automated — `emergency_flow_test` | ✅ Pass |
| T-33 | End the emergency | Resolved, sharing stopped | Event marked Resolved with an end time; sharing stopped | Automated — `emergency_flow_test` | ✅ Pass |
| T-34 | SOS without contacts | Blocked and explained | Start refused with `noContacts`; the UI offers to add one | Automated — `emergency_flow_test` | ✅ Pass |
| T-35 | Emergency is reachable from any tab | A persistent indicator | Red banner *"Emergency active • contacts notified"* above every tab, with OPEN | Manual | ✅ Pass |
| T-36 | An alert raises notifications | Notification centre updated | Notification count increased after activation | Automated — `emergency_flow_test` | ✅ Pass |
| T-36a | Cancel closes the SOS screen | The user is returned to where they came from | Screen closed and the dashboard was shown with the cancellation message | Automated — `widget_flow_test`; Manual | ✅ Pass |
| T-36b | A short press does not arm SOS | Nothing happens below the 3-second hold | Hold ring reset; no countdown started | Manual | ✅ Pass |

### 4.4 Location

| ID | Test case | Expected result | Actual result | Verified by | Status |
|---|---|---|---|---|---|
| T-37 | View location | Map, marker, coordinates, accuracy, timestamp | All shown; map labelled *"Simulated map view"* | Manual | ✅ Pass |
| T-38 | Start sharing | Sharing starts and lists the receivers | `isSharing` true; the receiving contacts recorded | Automated — `emergency_flow_test` | ✅ Pass |
| T-39 | Position updates while sharing | The marker moves | Coordinates changed over successive updates | Automated — `emergency_flow_test` | ✅ Pass |
| T-40 | Stop sharing | Sharing stops and receivers clear | `isSharing` false; receiver list emptied | Automated — `emergency_flow_test` | ✅ Pass |
| T-41 | Sharing requires permission | Cannot start without it | Start returned false while the permission was off | Automated — `emergency_flow_test` | ✅ Pass |
| T-42 | Sharing is confirmed first | Never starts silently | Confirmation dialog appears before sharing begins | Manual | ✅ Pass |
| T-43 | Sharing state is visible during an emergency | LIVE indicator | Live badge shown on the SOS screen and the map | Manual | ✅ Pass |

### 4.5 Emergency services

| ID | Test case | Expected result | Actual result | Verified by | Status |
|---|---|---|---|---|---|
| T-44 | View services | Four categories with numbers | Police, Ambulance, Fire Department, Emergency Hotline | Automated — `widget_flow_test`; Manual | ✅ Pass |
| T-45 | Demo numbers are labelled | The user is told they are fictional | Banner *"Demonstration numbers only"* at the top | Automated — `widget_flow_test`; Manual | ✅ Pass |
| T-46 | Call confirmation | Nothing is dialled without confirmation | Dialog *"SecureGuard will open your phone dialler with …"* | Manual | ✅ Pass |
| T-47 | Call on a device without telephony | A labelled demo response, and the attempt is logged | Demo dialog shown; an Emergency Call event was written to History | Manual | ✅ Pass |

### 4.6 History and notifications

| ID | Test case | Expected result | Actual result | Verified by | Status |
|---|---|---|---|---|---|
| T-48 | View history | Demo events with date, time, place, status | Five events plus a summary of totals | Automated — `widget_flow_test`; Manual | ✅ Pass |
| T-49 | Filter history | Only the chosen type is shown | Count changed to *"Showing 1 of 5 events"* | Automated — `widget_flow_test` | ✅ Pass |
| T-50 | New events are recorded | The latest event appears first | Completed SOS appeared at the top of the list | Automated — `emergency_flow_test`; Manual | ✅ Pass |
| T-51 | Event details | Timeline, map, contacts and notes | All sections rendered | Manual | ✅ Pass |
| T-52 | Delete an event | Removed from the history | History length decreased by one | Automated — `emergency_flow_test` | ✅ Pass |
| T-53 | Clear the history | All events removed | History became empty | Automated — `emergency_flow_test` | ✅ Pass |
| T-54 | Notification centre | Notifications with an unread count | Five notifications, two unread, badge on the dashboard | Automated — `widget_flow_test`; Manual | ✅ Pass |

### 4.7 Settings, theme and session

| ID | Test case | Expected result | Actual result | Verified by | Status |
|---|---|---|---|---|---|
| T-55 | Settings groups are present | Notifications, location, appearance, privacy | All four groups rendered with their controls | Automated — `widget_flow_test`; Manual | ✅ Pass |
| T-56 | Change the SOS countdown | The countdown length changes | Set to 10 s; row and confirmation updated; the next alert counted down from 10 | Manual | ✅ Pass |
| T-57 | Countdown picker shows the current choice | Selection is not colour-only | The selected option carries a tick as well as a highlight | Manual | ✅ Pass |
| T-58 | Dark mode | The whole app switches theme | Every screen switched; accents remained readable | Automated — `widget_flow_test`; Manual | ✅ Pass |
| T-59 | Dark mode persists | Theme survives a restart | Still dark after a full page reload | Manual | ✅ Pass |
| T-60 | Language setting | Choice saved, with a note about English-only text | Saved, and the note about future translation was shown | Manual | ✅ Pass |
| T-61 | Logout is blocked during an emergency | The user is warned rather than signed out | *"End the active emergency before logging out."* | Manual | ✅ Pass |
| T-62 | Logout | Returns to login; data is kept | Session cleared; contacts and history still present at next sign-in | Manual | ✅ Pass |

### 4.8 Persistence and resilience

| ID | Test case | Expected result | Actual result | Verified by | Status |
|---|---|---|---|---|---|
| T-63 | Data survives a restart | Contacts, history, settings and session persist | All restored after a full page reload | Manual | ✅ Pass |
| T-64 | Interrupted emergency | No event is left stuck as "active" | Unfinished events are resolved when the history loads | Automated — `emergency_flow_test` (load path) | ✅ Pass |
| T-65 | Storage unavailable | The app still works for the session | The whole test suite runs with no platform storage, using the in-memory fallback | Automated — every provider suite | ✅ Pass |
| T-66 | Corrupt stored data | Falls back to the demo data rather than crashing | Malformed JSON is caught and defaults are used | Automated — `LocalStore` guards, exercised by the provider suites | ✅ Pass |

## 5. Accessibility Checks

| Check | Method | Result |
|---|---|---|
| Status is never conveyed by colour alone | Visual inspection of every status pill | Every pill carries an icon and a word as well as a colour | ✅ Pass |
| Touch targets are large enough | Measured against the rendered layout | Buttons ≥ 48 dp; the SOS control is ~196 dp | ✅ Pass |
| Text scales without breaking the layout | System font scale increased | Readable; scaling is clamped to 0.9×–1.35× so the SOS button stays on screen | ✅ Pass |
| Icons are paired with text | Visual inspection | All navigation items, quick actions and buttons have both | ✅ Pass |
| Key controls are described to screen readers | `Semantics` labels reviewed in code | SOS button, countdown (live region), contacts, cards and services all labelled | ✅ Pass |
| Contrast in dark mode | Visual inspection of every screen in dark mode | Dark accents are lightened automatically by `AppColors.adaptive` | ✅ Pass |

---

## 6. Defects Found and Fixed During Testing

Testing was not a formality — it found real problems, which were fixed before
submission.

| # | Defect | How it was found | Fix |
|---|---|---|---|
| 1 | The splash screen's brand gradient covered only part of the screen, because the `Container` sized itself to its content rather than the viewport. | Browser screenshot at 390 × 844 | Replaced with `SizedBox.expand` + `DecoratedBox`. |
| 2 | Navy accent colours were almost invisible in dark mode (icon badges, quick actions, filter chips, avatars). | Dark-mode screenshot review | Added `AppColors.adaptive`, which lightens any accent that is too dark for a dark surface, applied across the shared widgets. |
| 3 | Restoring the session notified `AuthProvider`'s listeners during the first build, throwing an assertion. | Widget test on the real app widget | Deferred the call to a post-frame callback. |
| 4 | Two police services both showed a button reading "Call Police", so the button did not identify the service. | Screenshot review | Changed the label to "Call now" and moved the service name into the tooltip and semantics. |
| 5 | The "Emergency Services" quick-action subtitle was truncated mid-word. | Screenshot review | Shortened the label to "Direct emergency lines". |
| 6 | The onboarding button read "→ Next", with the arrow leading the label. | Screenshot review | Reordered so the label leads and the arrow follows. |
| 7 | The web build fetched its rendering engine from a CDN and rendered nothing without internet access. | Offline browser test | Configured the build to use the locally bundled engine, so the demo runs offline. |
| 8 | Signing in to the demo account with a mistyped password reported *"No account found for that email address"* instead of *"Incorrect password"*. | New `auth_service_test` case | The demo account is now matched on the email alone, so the password is validated separately. |
| 9 | Pressing **CANCEL ALERT** cancelled the alert but left the user on the SOS screen showing the "cancel the alert first" warning. `maybePop` consults the `PopScope` above, whose `canPop` still held the value from the frame before the cancellation. | Driving the running app in a browser | Leaving the screen now pops directly instead of through `maybePop`; covered by a new widget test (T-36a). |
| 10 | The web build baked `<base href="/">` into `index.html`, so the application only ran when served from a site root and showed a blank screen from any sub-path. | Hosting the build under a nested path | No base tag ships; the page probes for the directory it was actually served from and inserts the correct base before the engine loads. A startup-error panel now reports the address and error instead of hanging on the splash. |

---

## 7. Test Environment

| Item | Value |
|---|---|
| Flutter | 3.47.5 (stable) |
| Dart | 3.13.4 |
| Automated tests | `flutter test` on the Flutter test harness |
| Manual testing | Release web build served locally, Chromium at 390 × 844, device pixel ratio 2 |
| Screenshots | Captured from that same running build (`docs/screenshots/`) |

---

## 8. Summary

| Metric | Result |
|---|---|
| Automated tests | 79 |
| Automated tests passing | 79 (100%) |
| Analyzer issues | 0 |
| Documented test cases | 71 |
| Documented test cases passing | 71 (100%) |
| Accessibility checks | 6 of 6 passed |
| Defects found during testing | 10 |
| Defects fixed | 10 |
| Known open defects | 0 |

All planned functionality behaves as specified. The remaining gaps are the
deliberately simulated services documented in the README and in
`PROJECT_DOCUMENTATION.md` — they are scope decisions, not defects.
