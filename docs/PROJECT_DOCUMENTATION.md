# SecureGuard — Project Documentation

**A Mobile Application for Personal Safety and Emergency Assistance**

Final-year university mobile application project
Version 1.0.0 • Flutter / Dart

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Background](#2-background)
3. [Problem Statement](#3-problem-statement)
4. [Aim](#4-aim)
5. [Objectives](#5-objectives)
6. [Target Users](#6-target-users)
7. [Functional Requirements](#7-functional-requirements)
8. [Non-Functional Requirements](#8-non-functional-requirements)
9. [System Features](#9-system-features)
10. [Technology Stack](#10-technology-stack)
11. [System Architecture](#11-system-architecture)
12. [User Flow](#12-user-flow)
13. [Data Model](#13-data-model)
14. [Security Considerations](#14-security-considerations)
15. [Limitations](#15-limitations)
16. [Future Enhancements](#16-future-enhancements)
17. [Conclusion](#17-conclusion)

---

## 1. Introduction

SecureGuard is a mobile application for personal safety and emergency
assistance. It gives a person in danger one prominent control that
simultaneously alerts their trusted contacts, shares their location and opens a
path to the emergency services, and it keeps a record of what happened for use
afterwards.

This document describes the requirements, design, architecture and boundaries
of the system. It accompanies a complete, runnable Flutter application of
fifteen screens with an automated test suite.

The application is a **prototype built for academic assessment**. Features that
would require paid external services are simulated, and every simulation is
labelled both in this document and inside the application itself.

---

## 2. Background

Personal safety applications have grown steadily as smartphone ownership has
spread. The category generally provides some combination of an emergency
button, location sharing and a contact-alerting mechanism.

Three observations shaped this project:

**Speed matters more than features.** In an emergency, a person may have
seconds and one free hand. An application that requires navigating a menu has
already failed. The design therefore places a single large control on the first
screen after sign-in.

**Accidental activation is the main design risk.** A safety button that fires
easily produces false alarms, which erode the trust of the contacts who receive
them — so the real alarm is ignored. SecureGuard answers this with two barriers:
a deliberate three-second hold, then a cancellable countdown.

**Trust depends on honesty.** A safety application that overstates what it can
do is dangerous. This project therefore states clearly, in the app and in this
document, which capabilities are real and which are simulated.

The application is written in Flutter so that a single codebase produces
Android, iOS and web builds — practical for a student project that must be
demonstrated on whatever hardware is available on the day.

---

## 3. Problem Statement

When a person feels threatened or witnesses an emergency, the tools available
on a standard smartphone are slow and fragmented:

1. **Contacting help is too slow.** Unlocking the phone, opening the contact
   list, finding the right person and dialling takes too long under stress, and
   reaches only one person.
2. **Location cannot be communicated.** Describing an unfamiliar location by
   voice is difficult and error-prone, especially at night.
3. **Emergency numbers are not known.** Many people cannot recall the local
   ambulance or fire service number.
4. **Only one contact can be reached at a time.** Emergencies often call for
   several people to be alerted at once.
5. **No record survives.** When an incident must be reported later, the exact
   time, place and sequence of events are usually forgotten.

No single, simple tool solves all five problems together for a user who may
have only one hand free and a few seconds of attention.

---

## 4. Aim

To design, implement and evaluate a mobile application that enables a user to
raise an emergency alert, share their live location with trusted contacts and
reach the emergency services, using the smallest possible number of actions,
while protecting against accidental activation.

---

## 5. Objectives

| # | Objective | Met by |
|---|---|---|
| 1 | Provide a single, prominent emergency control on the main screen | `SosButton` on the dashboard and the SOS screen |
| 2 | Prevent accidental activation | 3-second press-and-hold plus a cancellable 3–15 second countdown |
| 3 | Alert multiple trusted contacts at once, primary contact first | `AlertService` dispatch ordered by priority |
| 4 | Let the user manage their trusted contacts | Trusted Contacts screen: add, edit, delete, set primary |
| 5 | Display and share the user's location | Live Location screen with map, start/stop sharing |
| 6 | Provide one-tap access to public emergency services | Emergency Services screen with per-category call buttons |
| 7 | Keep a permanent record of safety events | Emergency History with filtering and a detail view |
| 8 | Deliver an accessible, responsive interface | Material 3 themes, large targets, icon + text labels, width capping |
| 9 | Collect minimal personal data and explain what is stored | Privacy & data screen; local-only storage |
| 10 | Validate the implementation | 78 automated tests; documented test plan |

---

## 6. Target Users

**Primary users**

- *Students travelling to and from campus*, particularly for evening classes,
  who often walk or use shared transport after dark.
- *Commuters and lone workers* whose routines regularly place them alone in
  public space.
- *Anyone who sometimes feels unsafe* in unfamiliar areas or at night.

**Secondary users**

- *Trusted contacts* — family members and friends who receive the alerts. They
  do not use the application directly in this version; they receive a message
  containing the user's name and a map link.

**User characteristics assumed by the design**

- Comfortable with a smartphone but not necessarily technical.
- May be operating the phone one-handed, in poor light, while moving, and
  under stress.
- May have limited data connectivity.

These assumptions drive concrete design decisions: large touch targets, high
contrast, no reliance on colour alone, no multi-step flows before the SOS
control, and no dependency on a network connection to open the interface.

---

## 7. Functional Requirements

| ID | Requirement | Priority | Status |
|---|---|---|---|
| FR-01 | The system shall show a branded splash screen and route the user to onboarding, login or the dashboard depending on their state. | High | ✅ Implemented |
| FR-02 | The system shall present a three-page onboarding sequence on first launch, with skip and page indicators. | Medium | ✅ Implemented |
| FR-03 | The system shall allow a user to register with full name, email, phone number and password. | High | ✅ Implemented |
| FR-04 | The system shall allow a registered user to sign in, with an optional "remember me". | High | ✅ Implemented |
| FR-05 | The system shall allow a user to request a password reset. | Low | ⚠️ Simulated (no mail server) |
| FR-06 | The system shall provide a dashboard showing safety status, the SOS control, quick actions, contacts, location and recent activity. | High | ✅ Implemented |
| FR-07 | The system shall activate an emergency alert only after a deliberate 3-second press-and-hold. | High | ✅ Implemented |
| FR-08 | The system shall display a cancellable countdown before the alert is dispatched. | High | ✅ Implemented |
| FR-09 | The system shall refuse to start SOS when no trusted contact exists, and explain why. | High | ✅ Implemented |
| FR-10 | The system shall notify every trusted contact on activation, primary contact first. | High | ⚠️ Simulated dispatch |
| FR-11 | The system shall start live location sharing on activation, subject to the user's setting. | High | ✅ Implemented |
| FR-12 | The system shall record every activation, cancellation and resolution in the history. | High | ✅ Implemented |
| FR-13 | The system shall let the user end an active emergency and mark themselves safe. | High | ✅ Implemented |
| FR-14 | The system shall allow trusted contacts to be added, edited and deleted. | High | ✅ Implemented |
| FR-15 | The system shall allow exactly one contact to be marked primary, and shall always keep one. | High | ✅ Implemented |
| FR-16 | The system shall reject a trusted contact whose number duplicates an existing one. | Medium | ✅ Implemented |
| FR-17 | The system shall display the user's current position with an accuracy indicator. | High | ⚠️ Simulated GPS |
| FR-18 | The system shall let the user start and stop location sharing explicitly. | High | ✅ Implemented |
| FR-19 | The system shall list police, ambulance, fire and hotline services with call buttons. | High | ✅ Implemented (demo numbers) |
| FR-20 | The system shall open the device dialler when a service is called, after confirmation. | High | ✅ Implemented |
| FR-21 | The system shall provide safety tips in at least five categories. | Medium | ✅ Implemented (15 tips) |
| FR-22 | The system shall display a filterable history of safety events with a detail view. | High | ✅ Implemented |
| FR-23 | The system shall generate in-app notifications when significant actions occur. | Medium | ✅ Implemented |
| FR-24 | The system shall allow the user to view and edit their profile. | Medium | ✅ Implemented |
| FR-25 | The system shall provide settings for notifications, permissions, countdown length, theme and language. | Medium | ✅ Implemented |
| FR-26 | The system shall allow the user to change their password and to log out. | Medium | ✅ Implemented |
| FR-27 | The system shall retain user data between sessions on the same device. | High | ✅ Implemented |
| FR-28 | The system shall provide About and Privacy screens explaining the prototype's scope. | Medium | ✅ Implemented |

---

## 8. Non-Functional Requirements

| ID | Category | Requirement | How it is met |
|---|---|---|---|
| NFR-01 | Usability | A user must reach the SOS control within one action of signing in. | It is on the dashboard, the first screen after login. |
| NFR-02 | Usability | Error messages must be written in plain language and suggest what to do. | `Validators` returns user-facing sentences, e.g. *"Passwords do not match."* |
| NFR-03 | Performance | Screen transitions must feel immediate (< 300 ms). | Local state only; `IndexedStack` keeps tabs alive. |
| NFR-04 | Performance | The application must start in under three seconds on mid-range hardware. | No network calls at start-up; the splash is a deliberate 2.2 s brand moment. |
| NFR-05 | Reliability | Storage failures must not crash the application. | `LocalStore` catches every storage error and falls back to memory. |
| NFR-06 | Reliability | An emergency interrupted by app closure must not be left "active". | Unfinished events are resolved on the next load. |
| NFR-07 | Accessibility | Text must remain readable when the system font scale is increased. | Text scaling is honoured and clamped to 0.9×–1.35×. |
| NFR-08 | Accessibility | Status must never be conveyed by colour alone. | Every status pill carries an icon and a word as well as a colour. |
| NFR-09 | Accessibility | Interactive elements must meet minimum touch-target sizes. | Buttons are ≥ 48 dp; the SOS control is ~196 dp. |
| NFR-10 | Accessibility | Screen readers must be able to describe key controls. | `Semantics` labels on the SOS button, cards, contacts and the countdown. |
| NFR-11 | Portability | One codebase must build for Android, iOS and web. | Flutter; verified with Android, iOS and web build targets. |
| NFR-12 | Responsiveness | The layout must work from small phones to tablets and desktop browsers. | `Responsive` breakpoints; content width capped at 560 dp and centred. |
| NFR-13 | Maintainability | UI, state, logic and data must be separated. | Four-layer architecture (see §11). |
| NFR-14 | Maintainability | The code must pass static analysis with no issues. | `flutter analyze` → *No issues found!* |
| NFR-15 | Testability | Core logic must be covered by automated tests. | 78 tests across six suites. |
| NFR-16 | Privacy | Only data required for the safety function may be collected. | Name, email, phone, contacts, position, history — nothing else. |
| NFR-17 | Security | Sensitive input must be masked by default. | Password fields are obscured with an explicit show/hide control. |
| NFR-18 | Transparency | The prototype's limits must be visible to the user. | About and Privacy screens; banners on every simulated feature. |

---

## 9. System Features

### 9.1 Authentication
Registration with validated fields and a live password-strength meter; sign-in
against locally stored accounts plus a built-in demonstration account; optional
"remember me" session restore; password change; and logout with confirmation.

### 9.2 Emergency SOS
The core feature, implemented as an explicit state machine with four states —
`idle`, `countdown`, `dispatching`, `active`:

1. **Hold.** The user presses and holds for three seconds. A ring fills around
   the button and haptic feedback marks each second.
2. **Countdown.** A large, cancellable countdown runs for the configured
   duration (default 5 seconds), listing the contacts who will be notified.
3. **Dispatch.** Contacts are notified one at a time, primary first, with the
   UI showing each one being reached. Location sharing starts in parallel.
4. **Active.** The alert view shows the activation time, a running duration,
   the location, sharing status and the delivery state of every contact, plus
   controls to call the emergency services, send the location by message or
   end the emergency.

Cancelling during the countdown is recorded as a *cancelled* event with no
contacts notified — an important distinction for the history.

### 9.3 Trusted Contacts
Full management of the people who receive alerts. Exactly one contact is
primary at any time; the system promotes another automatically if the primary
contact is deleted, and never leaves the list without one. Numbers are checked
for duplicates.

### 9.4 Live Location
A map view with the current position, an accuracy circle, a live indicator and
zoom controls. Sharing is explicit: the user confirms before it starts, the
position updates every few seconds while it runs, and the list of receiving
contacts is shown. Sharing can be stopped in one tap, and stops automatically
when the emergency ends or the location permission is withdrawn.

### 9.5 Emergency Services
Seven services in four categories (police, ambulance, fire, hotline), each with
a description, availability and a call button that opens the device dialler
after a confirmation step. Every call attempt is written to the history.

### 9.6 Emergency History
An automatically maintained log of four event types — SOS alerts, location
shares, emergency calls and safety check-ins — each with a status of active,
resolved or cancelled. Filterable by type, with a summary of totals, a full
detail view and per-event or bulk deletion.

### 9.7 Safety Tips
Fifteen concise, practical tips in five tabbed categories: personal, travel,
night, online and emergency preparedness. Cards expand to reveal the full
advice.

### 9.8 Notifications
An in-app notification centre. Entries are generated as the user acts —
contact added, location sharing started, SOS sent, emergency ended — with
unread counts, swipe-to-dismiss and mark-all-read.

### 9.9 Profile and Settings
Editable profile including optional blood group and home area for responders;
protection statistics; and settings for notifications, emergency sound,
location permission, automatic sharing during SOS, countdown length, dark mode,
language, lock-screen privacy, password and demo-data reset.

---

## 10. Technology Stack

| Layer | Technology | Version | Justification |
|---|---|---|---|
| Framework | Flutter | 3.47 | Single codebase across Android, iOS and web; rich widget set; strong tooling for a student project. |
| Language | Dart | 3.13 | Sound null safety, pattern matching, records — fewer runtime errors. |
| UI system | Material 3 | built in | Modern components with theming and accessibility already handled. |
| State management | provider | ^6.1.2 | `ChangeNotifier` is simple enough to explain in a viva while still scaling to six providers. |
| Local storage | shared_preferences | ^2.3.2 | Key/value persistence that works identically on all target platforms. |
| Platform integration | url_launcher | ^6.3.0 | Opens the dialler and SMS composer through the OS. |
| Testing | flutter_test, fake_async | bundled / ^1.3.2 | Widget testing plus virtual clocks for the timer-driven SOS flow. |
| Static analysis | flutter_lints | ^6.0.0 | The standard Dart/Flutter rule set. |

**Rejected alternatives and why.** *Bloc* was considered for state management
but adds significant boilerplate for a project this size. *Firebase* was
rejected because it would require a billing account and would move the project
away from a self-contained, offline demonstration. *Google Maps* was rejected
for the same reason, and replaced by a drawn map.

---

## 11. System Architecture

SecureGuard uses a four-layer architecture. Dependencies point in one direction
only: presentation depends on state, state depends on services, services depend
on models.

```
┌──────────────────────────────────────────────────────────────┐
│  PRESENTATION           lib/screens/  lib/widgets/  lib/theme/│
│  Screens draw and collect input. They hold no business logic. │
└───────────────────────────┬──────────────────────────────────┘
                            │ watch / read
┌───────────────────────────▼──────────────────────────────────┐
│  STATE                    lib/providers/                      │
│  ChangeNotifier classes hold app state and coordinate work.   │
│  Auth · Contacts · Emergency · Location · Notifications ·     │
│  Settings                                                     │
└───────────────────────────┬──────────────────────────────────┘
                            │ calls
┌───────────────────────────▼──────────────────────────────────┐
│  SERVICES / DATA          lib/services/  lib/data/            │
│  Auth · Alert · Location · Dialer · LocalStore · DemoData     │
│  All external-world interaction is isolated here.             │
└───────────────────────────┬──────────────────────────────────┘
                            │ produces
┌───────────────────────────▼──────────────────────────────────┐
│  MODELS                   lib/models/                         │
│  Immutable data classes with JSON serialisation.              │
└──────────────────────────────────────────────────────────────┘
```

**Why the layering matters here.** Every simulated capability lives in exactly
one service class. Replacing the simulated GPS with a real one means rewriting
`LocationService` alone; `LocationProvider`, the location screen and the SOS
flow are untouched. The same is true of `AlertService` for real SMS delivery
and `MockMap` for a real map widget.

**Provider composition.** The five independent providers are registered
directly. `EmergencyProvider` depends on three of them, so it is registered as
a `ChangeNotifierProxyProvider3` and receives its collaborators through an
`attach()` method — keeping the dependency explicit and easy to substitute in
tests.

**Navigation.** Named routes are declared in `main.dart` and their names are
centralised in `AppRoutes`. The signed-in area lives inside `RootShell`, which
uses an `IndexedStack` so each of the five tabs keeps its scroll position and
state. A persistent red banner appears above the tabs whenever an emergency is
running, so it is reachable from anywhere in the app.

**Persistence.** `LocalStore` wraps `shared_preferences` and converts every
storage failure into a silent fallback to an in-memory map, so a device that
denies storage degrades to a working session rather than a crash.

---

## 12. User Flow

### 12.1 Primary flow — raising an emergency alert

```
Open app
   ↓
Splash (2.2 s, restores session)
   ↓
[First launch?] ──yes──► Onboarding (3 pages) ──► Login
   │ no
   ↓
[Remembered session?] ──yes──► Dashboard
   │ no
   ↓
Login  ──(demo account or registered account)──►  Dashboard
   ↓
Press and HOLD the SOS button for 3 seconds
   ↓
[Any trusted contacts?] ──no──► "Please add at least one emergency contact
   │                             before activating SOS."  ──► Contacts
   │ yes
   ↓
COUNTDOWN (default 5 s)  ──cancel──► logged as "Cancelled", nobody notified
   ↓ (expires)
DISPATCH  → contact 1 notified → contact 2 notified → contact 3 notified
          → live location sharing starts
   ↓
EMERGENCY ACTIVE
   • activation time and running duration
   • current location and coordinates
   • every contact shown as notified
   • Call emergency services / Send location by message
   ↓
"I'm safe — End emergency"  (confirmation)
   ↓
Event marked RESOLVED · sharing stops · contacts informed
   ↓
History tab shows the completed event
```

### 12.2 Secondary flows

**Managing contacts:** Contacts tab → Add → name, relationship, phone,
optional primary → validated → saved → notification raised.

**Sharing location:** Location tab → Share my live location → confirm → map
shows LIVE, position updates, receiving contacts listed → Stop sharing.

**Calling a service:** Emergency Services → choose a service → Call now →
confirm → dialler opens (or a labelled demo dialog) → attempt logged.

**Reviewing an incident:** History tab → filter by type → open an event →
timeline, map, contacts notified and notes.

---

## 13. Data Model

Seven model classes, all immutable with `copyWith` and JSON serialisation.

| Model | Key fields | Notes |
|---|---|---|
| `AppUser` | id, fullName, email, phone, bloodGroup, address | Derives `initials` and `firstName` for the UI. |
| `EmergencyContact` | id, name, relationship, phone, isPrimary | Exactly one contact is primary at a time. |
| `EmergencyEvent` | id, type, startedAt, endedAt, locationLabel, latitude, longitude, status, notifiedContactNames, locationShared, note | `type` ∈ {sosAlert, locationShare, serviceCall, safetyCheck}; `status` ∈ {active, resolved, cancelled}. |
| `EmergencyService` | id, name, category, phoneNumber, description, availability | `category` ∈ {police, ambulance, fire, hotline}. |
| `SafetyTip` | id, category, title, body | `category` ∈ {personal, travel, night, online, preparedness}. |
| `AppNotification` | id, type, title, message, createdAt, isRead | `type` ∈ {sos, contact, location, reminder, system}. |
| `LocationStatus` | latitude, longitude, addressLabel, accuracyMeters, updatedAt, isSharing, permissionGranted, sharedWith | Derives a formatted coordinate string and a status label. |

**Relationships.** A user owns many contacts, many events and many
notifications. An event references the contacts notified by name, so the
history stays readable even after a contact is deleted — a deliberate choice,
because a historical record should not change when current data does.

**Storage keys.** Data is namespaced under `sg_*` keys in
`shared_preferences`: `sg_user`, `sg_contacts`, `sg_events`,
`sg_notifications`, `sg_settings`, `sg_registered_accounts`,
`sg_is_logged_in`, `sg_remembered_email` and `sg_onboarding_seen`.

---

## 14. Security Considerations

### 14.1 Data minimisation
The application asks only for what the safety function needs: a name so
contacts know who is calling for help, an email for sign-in, a phone number so
alerts are recognisable, the trusted contacts themselves, the current position
and the event history. Blood group and home area are optional and exist purely
to help a responder.

### 14.2 What is implemented

| Control | Implementation |
|---|---|
| Input validation | Every field is validated before submission (`Validators`). |
| Password masking | Obscured by default with an explicit show/hide toggle. |
| Password strength | Registration requires 8+ characters with letters and numbers; a live meter shows strength. |
| Accidental-activation protection | 3-second hold plus a cancellable countdown. |
| Explicit consent for sharing | Location sharing always requires a confirmation dialog. |
| Destructive-action confirmation | Deleting a contact, clearing history and logging out all confirm first. |
| Permission awareness | Location permission is a visible, revocable setting; revoking it stops sharing immediately. |
| Lock-screen privacy | A setting keeps trusted contacts out of notification previews. |
| Local-only storage | Nothing is transmitted off the device. |

### 14.3 What is *not* implemented — and why that is stated openly

This is a prototype for academic assessment, not a shipped product:

- **Passwords are stored unhashed** in `shared_preferences`. A production
  version must store only a salted hash, and server-side.
- **There is no encryption at rest.** Device storage is used as-is.
- **There is no server-side authentication**, so there is no protection
  against credential-stuffing, no rate limiting and no session revocation.
- **There is no transport security to consider**, because there is no
  transport — but adding a backend would require TLS and certificate pinning.
- **No independent security review or penetration test** has been performed.

These limitations are repeated on the **Settings → Privacy & data** screen
inside the application so that a person using the demonstration is never
misled about how much protection it offers.

### 14.4 Ethical considerations
Publishing incorrect emergency numbers could cause real harm, so the
application ships clearly fictional demonstration numbers with a banner saying
so. Likewise, the application never claims an alert has reached a contact
through a channel it does not have; the dispatch is described as an in-app
simulation. The About screen tells the user plainly not to rely on the
prototype during a genuine emergency.

---

## 15. Limitations

1. **No backend.** Data lives on one device; nothing synchronises, and
   uninstalling the app removes everything.
2. **Alerts do not leave the device.** Contact notification is simulated.
3. **Positioning is simulated.** Coordinates come from a generated feed rather
   than device GPS.
4. **The map is illustrative.** It is drawn with `CustomPainter`, not a real
   geographic map.
5. **Emergency numbers are fictional** and must be replaced before real use.
6. **Security is not production-grade** (see §14.3).
7. **The interface is English only**, although the language preference is
   stored.
8. **Portrait orientation only.**
9. **No background operation** — the application must be open for SOS to be
   triggered.
10. **Evaluation was informal.** The project was tested by the developer with
    an automated suite and a documented manual pass, not with a user study.

---

## 16. Future Enhancements

**Short term (next iteration)**
1. Real SMS delivery through an SMS gateway, with push notifications for
   contacts who have the app installed.
2. Real GPS via `geolocator`, with proper runtime permission handling.
3. A real map widget replacing `MockMap`.
4. Full localisation into Somali and Arabic using `flutter_localizations`.

**Medium term**
5. A secure backend with hashed credentials, encrypted storage and
   multi-device synchronisation.
6. Background activation — a shake gesture or power-button sequence, so SOS
   works without unlocking the phone.
7. Automatic audio or video capture during an alert, stored securely as
   evidence.
8. A responder web view where a notified contact can follow the live location
   and confirm they are responding.

**Long term**
9. Safe-route guidance that prefers well-lit, busier streets at night.
10. Integration with official emergency dispatch systems where an API exists.
11. Wearable support (smartwatch SOS).
12. A formal accessibility audit against WCAG 2.2, and a user study with the
    target population to evaluate real-world effectiveness.

---

## 17. Conclusion

This project set out to build a mobile application that shortens the distance
between a person in danger and the help they need. The result is SecureGuard: a
complete Flutter application of fifteen screens in which a user can sign in,
hold one button for three seconds, cancel if it was a mistake, and otherwise
have every trusted contact alerted with their live location — with the whole
incident recorded for afterwards.

All twenty-eight functional requirements are satisfied: twenty-five fully, and
three through documented simulations of services a student project cannot pay
for. The non-functional requirements around usability, accessibility,
reliability, maintainability and testability are met and evidenced by a clean
static analysis and 78 passing automated tests.

The engineering contribution is the layered architecture that isolates every
simulation behind a single service class, so the prototype can become a real
product by replacing files rather than rewriting the application. The design
contribution is the two-stage activation model — hold, then countdown — which
takes accidental activation seriously as the principal risk in this category of
software.

The project's most important quality, though, may be its honesty. Every
simulated capability is labelled inside the application, and the privacy screen
states plainly that the prototype is not production-secure. A safety
application that overstates its capabilities is more dangerous than no
application at all; building one that says exactly what it can and cannot do is
part of engineering it responsibly.
