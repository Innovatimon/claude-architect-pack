# Runbook: User-Anleitung erstellen
> Klassifikation: L2

> **Trigger:** "User-Anleitung schreiben", "Action-Datei erstellen", "Manual-Step dokumentieren", "Schritt fuer User vorbereiten"

## Wann eine User-Anleitung schreiben?

Wenn der Agent auf einen **echten Stop-Punkt** trifft (Top-Doktrin):
- Credential / API-Key fehlt
- Webseiten-Login den nur der User hat
- Bezahl-Aktion ohne Autorisierung
- Hardware-Aktion (USB-Stick einlegen, Server neustarten)
- Strategische Entscheidung mit mehreren legitimen Wegen
- Destruktive Ambiguitaet (loeschen ja/nein)

**Kein Stop-Punkt:** "Build koennte failen", "Tests koennten rot sein", "Welche Variante besser ist" — selbst entscheiden mit Architekt-Default.

## Wo wird die Anleitung abgelegt?

```
<workspace-root>/_schriftbuero/User-Anleitungen/ACT-YYYY-MM-DD-NNN-<topic>.md
```

Schriftbuero-Verzeichnis nicht vorhanden? Skill `~/.claude/skills/project-setup/SKILL.md` oder Runbook `schriftbuero-erstellen.md` ausfuehren.

## Pflicht-Format

```markdown
# ACT-YYYY-MM-DD-NNN — <Topic>

> Status: OFFEN | Erledigt
> Prioritaet: P0 | P1 | P2
> Erstellt: <Datum>
> Erstellt-von: <Agent-Bezeichnung>

## Warum (1-2 Saetze)

Was hat den Stop ausgeloest? Was haengt davon ab?

## Was du tun musst (konkrete Schritte)

1. Schritt 1 mit copy-paste-ready Befehlen
2. Schritt 2 mit Screenshots-Hinweisen falls UI
3. Schritt 3 mit Erfolgskriterium

## Erwartete Antwort vom User

Was soll der User zurueckmelden? z.B.:
- "Credential gesetzt" (mit Datei-Pfad)
- "Account erstellt" (mit Email)
- "Done" (Knopf gedrueckt)

## Was der Agent danach tut

Wenn der User "Done" sagt, macht der Agent automatisch:
1. ...
2. ...

## Notizen / Inline-Antworten

(Hier kann der User direkt Notizen hinterlassen.)
```

## Inline-Konversation-Pattern

User kann **direkt in der Datei** antworten (statt im Chat), z.B.:

```markdown
## Was du tun musst

1. Geh zu https://example.com/admin
2. Logge dich ein mit deinem Account
3. Klick auf "API-Key erstellen"

---
USER (2026-05-11): Done, Key liegt in ~/.config/credentials/example-api.txt
---

4. Agent: Key auslesen, in .env eintragen
```

Der naechste Agent sieht den `---USER:---` Block und arbeitet weiter.

## Konsolidierung in Master-Action-Index

Nach Erstellung in `<workspace-root>/_schriftbuero/MASTER-ACTIONS.md` eintragen:

```markdown
| ID | Topic | Prio | Status | Pfad |
|----|-------|------|--------|------|
| ACT-2026-05-11-001 | Stripe Live-Switch | P0 | OFFEN | `User-Anleitungen/ACT-2026-05-11-001-stripe-live.md` |
```

## Cleanup nach Erledigung

Wenn User "Erledigt" markiert:
1. **VOR Archivierung:** Body nach Inline-User-Wuenschen scannen
   (typisch `---USER:---` Bloecke). Wenn der User dort neue Folge-Wuensche
   hinterlassen hat -> NEUE Action-Datei anlegen.
2. Status auf "Erledigt" im File-Header setzen
3. Status in MASTER-ACTIONS auf "Erledigt"
4. File-Inhalt bleibt — wird beim naechsten Schriftbuero-Konsolidieren ins `_archive/` verschoben.

## Verifizieren

- [ ] File-Pfad korrekt: `_schriftbuero/User-Anleitungen/ACT-YYYY-MM-DD-NNN-<topic>.md`
- [ ] Pflicht-Sektionen vorhanden: Warum / Was du tun musst / Erwartete Antwort / Was der Agent danach tut
- [ ] Eintrag in `MASTER-ACTIONS.md` vorhanden
- [ ] Im Chat: User wurde explizit darauf hingewiesen (Format: "BLOCKED weil X, ACT-... angelegt, naechster Schritt Y")

## Learnings

### Inline-Konversation > Chat-Konversation
Wenn der User die Anleitung als Bookmark behaelt, hat er Kontext beim Antworten. Im Chat geht der Kontext nach 2 Wochen verloren.

### Erledigt-Markierung NIE Folge-Wuensche schlucken
Cleanup-Pruefung beim Archivieren ist Pflicht. Eine "Erledigt"-Markierung kann versteckte neue Anweisungen enthalten — vor `mv ins _archive/` Body-Scan.

### Action-IDs sind eindeutig
Format `ACT-YYYY-MM-DD-NNN` mit NNN = laufende Nummer pro Tag. Cross-Reference aus Code, Audits, Status-Files moeglich.
