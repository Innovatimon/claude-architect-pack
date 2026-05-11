---
name: project-setup
description: Erstellt die Standard-Dokumentationsstruktur fuer ein neues oder bestehendes Projekt. Aktivieren bei "neues Projekt", "Projekt einrichten", "Struktur erstellen", "Dokumentation anlegen", "Projekt bootstrappen" oder wenn ein Projekt-Ordner keine CLAUDE.md hat.
---

# Project-Setup — Persona

Du legst ein neues Projekt im Workspace strukturiert an.

## Wann aktivieren

- "Neues Projekt" / "Projekt anlegen" / "bootstrappen" / "leg <X> als Projekt an"
- Projekt-Ordner ohne `CLAUDE.md`
- Sub-Projekt unter bestehendem L7-Eltern

## Step-by-Step

> **Single-Source-of-Truth fuer Schritte:** `_runbooks/neues-projekt-erstellen.md`
> Lies dieses Runbook und arbeite es ab. Es enthaelt alle 8 Schritte:
> Klassifikation (L1-L7), Verzeichnis, 5 Pflicht-Files (CLAUDE.md / VISION.md /
> STATUS.md / PROJECT.md / SETUP.md), optionales Schriftbuero, Git-Repo,
> Workspace-Root-CLAUDE.user.md-Update, Memory-Eintrag, Cloud Scheduled Task.

## Doktrin (Persona-Pflicht)

- **L1-L7-Klassifikation Pflicht** (siehe Root-`CLAUDE.md`). Im Zweifel spezifischer als globaler.
- **5 Pflicht-Files** sind nicht verhandelbar: `CLAUDE.md`, `VISION.md`, `STATUS.md`, `PROJECT.md`, `SETUP.md`.
- **STATUS.md-Pflicht (verstaerkt):** Nach JEDER Welle MUSS `STATUS.md` ueberschrieben werden — kein Append, kein Diff, ganz neu. Pflicht-Template: `_control/templates/status-template.md`. Pflicht-Sektionen: Letzte Welle (ID + Datum + Outcome), Live-URLs / BUILD_ID, Final-Scores / Pass-Fail, Offene Bugs, Naechster Schritt. Kein HANDOFF.md / SESSION-* / HOLDING_* / CURRENT-AUDIT.md. Git-Log ist das Archiv. Verstoss = sofortiges Re-Audit durch Skill `cleanup-after-welle`.
- **Umlaut-Pflicht** (Root-CLAUDE.md): UI/User-Texte mit echten Umlauten, interne Agent-Doku ASCII.
- **Keine Credentials in Docs** — nur Pfade auf `_control/credentials-map.md`.
- **GitHub-Account:** Wert aus `CLAUDE.user.md` Sektion "GitHub" — falls nicht gesetzt, einmalig fragen.

## Boundaries

- L5 (Framework/Group) ≠ L7 (Einzel-Projekt). Ein Group-Projekt unter `Projekte/<group>/Sub/<name>/`, ein Einzel-Projekt unter `Projekte/<name>/`.
- Sub-Projekte erben L-Klasse vom Eltern.
- Schriftbuero nur bei "viel User-Input + Uploads" — kein Default.

## Quick-Templates

Minimal-Vorlagen fuer alle 5 Files siehe Runbook `_runbooks/neues-projekt-erstellen.md`.
