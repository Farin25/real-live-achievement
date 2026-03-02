# CONTRIBUTING

# Deutsche Version

## Beitragsrichtlinien

Vielen Dank für dein Interesse an diesem Projekt.

Um eine saubere, wartbare und professionelle Codebasis sicherzustellen, gelten folgende verbindliche Regeln.

---

## 1. Allgemeine Grundsätze

- Beiträge müssen fokussiert und nachvollziehbar sein.
- Keine nicht zusammenhängenden Änderungen in einem Commit bündeln.
- Größere Architekturänderungen müssen vor der Umsetzung besprochen werden.
- Kommunikation erfolgt respektvoll und sachlich.

---

## 2. Commit-Message-Regeln (Verpflichtend)

Alle Commits müssen folgendes Format verwenden:

```
type(scope): kurze Beschreibung
```

Optional kann unter der ersten Zeile eine genauere Erklärung stehen.

### Erlaubte Typen

- `feat` – neue Funktion
- `fix` – Fehlerbehebung
- `refactor` – interne Umstrukturierung ohne Funktionsänderung
- `docs` – nur Dokumentation
- `style` – Formatierung ohne Logikänderung
- `perf` – Performance-Verbesserung
- `test` – Tests hinzufügen oder anpassen
- `chore` – Wartungsarbeiten

### Beispiele (Erlaubt)

```
feat(auth): E-Mail-Verifizierung hinzufügen
```

```
fix(api): Absturz bei null Antwort verhindern
```

### Unzulässig

```
update
```

```
irgendwas
```

```
kein bock mehr
```

---

## 3. Commit-Struktur

- Nicht jede einzelne Zeilenänderung separat committen.
- Keine Sammel-Commits mit vielen nicht zusammenhängenden Änderungen.
- Ein Commit muss genau eine logische Änderung enthalten.

---

## 4. Changelog-Pflicht (Verbindlich)

Alle nutzerrelevanten Änderungen müssen in `CHANGELOG.md` dokumentiert werden.

Dazu gehören:

- Neue Funktionen
- Fehlerbehebungen
- Verhaltensänderungen
- Entfernte Funktionen

Pull Requests ohne entsprechendes Changelog-Update können abgelehnt werden.

Beispiel:

```
## [Unreleased]

### Hinzugefügt
- E-Mail-Verifizierungssystem

### Behoben
- Login-Absturz bei null API-Antwort
```

---

## 5. Pull-Request-Anforderungen

Vor dem Einreichen eines Pull Requests:

- Das Projekt muss erfolgreich builden.
- Kein Debug- oder Testcode darf verbleiben.
- Commit-Messages müssen den Vorgaben entsprechen.
- `CHANGELOG.md` muss bei Bedarf aktualisiert sein.

Maintainer behalten sich das Recht vor, Beiträge bei Nichteinhaltung der Regeln abzulehnen.

---

---

# English Version

## Contribution Guidelines

Thank you for your interest in contributing to this project.

To maintain a clean, maintainable, and professional codebase, the following rules are mandatory.

---

## 1. General Principles

- Contributions must be focused and understandable.
- Do not combine unrelated changes in one commit.
- Major architectural changes must be discussed before implementation.
- Communication must remain respectful and constructive.

---

## 2. Commit Message Rules (Mandatory)

All commits must follow this format:

```
type(scope): short summary
```

An optional detailed explanation may follow below the first line.

### Allowed Types

- `feat` – new feature
- `fix` – bug fix
- `refactor` – internal restructuring without behavior change
- `docs` – documentation only
- `style` – formatting only (no logic changes)
- `perf` – performance improvements
- `test` – adding or modifying tests
- `chore` – maintenance tasks

### Examples (Allowed)

```
feat(auth): add email verification
```

```
fix(api): prevent crash on null response
```

### Unacceptable

```
update
```

```
random stuff
```

```
no motivation
```

---

## 3. Commit Structure

- Do not commit every single line change separately.
- Do not bundle multiple unrelated changes into one commit.
- One commit must represent one logical change.

---

## 4. Changelog Requirement (Mandatory)

All user-facing changes must be documented in `CHANGELOG.md`.

This includes:

- New features
- Bug fixes
- Behavior changes
- Removed functionality

Pull requests without proper changelog updates may be rejected.

Example:

```
## [Unreleased]

### Added
- Email verification system

### Fixed
- Login crash when API returns null
```

---

## 5. Pull Request Requirements

Before submitting a pull request:

- The project must build successfully.
- No debug or temporary code may remain.
- Commit messages must follow the required format.
- `CHANGELOG.md` must be updated when applicable.

Maintainers reserve the right to reject contributions that do not comply with these rules.
