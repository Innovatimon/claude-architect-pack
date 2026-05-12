# Runbook: Schriftbuero fuer ein Projekt anlegen
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "Schriftbuero anlegen", "Schriftbuero fuer <Projekt>", "ich brauche Inbox + Briefings", "User-Kommunikations-Layer", "wir brauchen einen Ort fuer Uploads und Fragen"

## Kontext

Ein Schriftbuero ist die persistente schriftliche Kommunikations-Schicht zwischen
User (Owner) und Architekt (Claude). Es ist sinnvoll, wenn ein Projekt
**lange laeuft, viel User-Input braucht und Material persistiert werden muss**
(PDFs, Persona-Specs, Server-Logs, Fotos).

Erste Anwendung: `Projekte/MultiBrandShops/_schriftbuero/`. Zweite Anwendung:
`Projekte/ProjectZeta/ProjectEpsilon/_schriftbuero/`. Beide haben dieselbe Struktur.

## Wann brauche ich kein Schriftbuero?

- Kurz-Projekte (Bug-Fix, einmaliger Setup, Migration).
- Rein technische Projekte ohne User-Input-Bedarf (Server-Patch, Doku-Aufraeumen).
- Wenn der Chat als Single-Source-of-Truth voll reicht.

Wenn du unsicher bist: **lass es weg, nachruesten ist trivial**. Erst wenn klar
wird, dass Wissen verloren geht oder der User Material liefern muss, lege es an.

## Schritte

### 1. Klassifikation festlegen

| Aspekt | Antwort |
|--------|---------|
| Schriftbuero-Verzeichnis-Ort | `<Projekt>/_schriftbuero/` (im Projekt selbst, nicht global) |
| Zugriff fuer Sub-Agenten | read-only, ausser explizit im Audit erlaubt |
| Schriftbuero-Pattern (das Konzept) | L2 (gilt fuer alle Projekte, dieses Runbook hier) |

### 2. Verzeichnis-Skelett anlegen

```powershell
# Windows / PowerShell
$base = "C:\Users\YourUser\.YourWorkspace\Projekte\<Projekt-Pfad>\_schriftbuero"
foreach ($d in @("Templates","Inbox","Briefings","Fragenkataloge","Antworten","Kontinuitaet")) {
  New-Item -ItemType Directory -Force -Path "$base\$d" | Out-Null
}
```

```bash
# Unix
mkdir -p "<Projekt>/_schriftbuero"/{Templates,Inbox,Briefings,Fragenkataloge,Antworten,Kontinuitaet}
```

### 3. README schreiben

`<Projekt>/_schriftbuero/README.md` erklaert das Konzept und den Workflow fuer
User + Agenten. Pattern: siehe
`Projekte/ProjectZeta/ProjectEpsilon/_schriftbuero/README.md` (oder
`Projekte/MultiBrandShops/_schriftbuero/README.md` fuer Multi-Projekt-Variante).

Pflicht-Sektionen:
- "Was ist das?" (drei Bullets: Inbox, Briefings, Fragenkataloge)
- Verzeichnis-Tabelle
- Workflow fuer den User (A. Upload, B. Fragenkatalog beantworten, C. Stand checken)
- Workflow fuer den Architekt (Wann was schreiben?)
- Anti-Halluzinations-Regel fuer Sub-Agents
- Pflege-Hinweis am Ende

### 4. Templates kopieren

5 Template-Files in `Templates/`:

- `Briefing-Template.md` — Architekt → User Statusbericht
- `Fragenkatalog-Template.md` — Architekt → User strukturierte Fragen
- `Antwort-Template.md` — User → Architekt Antworten
- `Initiator-Template.md` — Pflicht-Lektuere fuer naechsten Agent
- `Inbox-Eintrag-Template.md` — Begleitnotiz fuer User-Uploads

Kopiere die Vorlagen aus
`Projekte/ProjectZeta/ProjectEpsilon/_schriftbuero/Templates/` und passe das `projekt:`-Frontmatter-Feld an.

### 5. Inbox/README schreiben

`<Projekt>/_schriftbuero/Inbox/README.md` ist die User-Anleitung fuer Uploads:
- Welche Datei-Typen sind okay?
- Naming-Konvention `YYYY-MM-DD-thema.<ext>`
- Begleitnotiz-Pattern (parallele .md mit gleichem Praefix)
- Vertraulichkeit (keine Klartext-Credentials!)
- Was passiert nach Upload?
- URGENT-Praefix fuer dringende Sachen

Pattern: siehe `Projekte/ProjectZeta/ProjectEpsilon/_schriftbuero/Inbox/README.md`.

### 6. Erstes Briefing schreiben

Sofort nach dem Schriftbuero-Setup ein erstes Briefing in `Briefings/` ablegen:
`<datum>-Welle-1-Bericht.md`. Inhalt:
- Drei-Saetze-Zusammenfassung
- Was haben wir geliefert?
- Wieso?
- Was kam ueberraschend?
- Was kann der User jetzt tun?

Damit weiss der User sofort, dass das Schriftbuero produktiv ist.

### 7. Ersten Initiator schreiben

`Kontinuitaet/<datum>-Welle-1-Initiator.md` mit:
- "In 30 Sekunden" (3 Bullets)
- "In 5 Minuten" (Welle-Status, Audits, Worker, offene Fragen)
- "In 30 Minuten" (Pflicht-Lektuere, Optional-Lektuere)
- "Naechster sinnvoller Schritt"
- "Was darfst du NICHT?" (Boundaries)
- Risiko-Liste

So kann ein neuer Agent nach Terminal-Neustart in 5 Minuten produktiv weitermachen.

### 8. Ersten Fragenkatalog schreiben (wenn User-Input ansteht)

Wenn User-Entscheidungen offen sind: `Fragenkataloge/Q1-<thema>.md`. Pattern:
- 5-20 Fragen, gruppiert in Kategorien (A, B, C, ...)
- Pro Frage: `frage`, `typ`, `optionen`, `begruendung`, `default_arch`, `antwort`, `user_status`
- Antwort-Typen: single-choice, multi-select, free-text, yes-no, numeric, prio-ranking

### 9. Im Projekt-CLAUDE.md verweisen

`<Projekt>/CLAUDE.md` muss eine Sektion "## Schriftbuero" haben:

```markdown
## Schriftbuero
Dieses Projekt hat ein eigenes Schriftbuero unter `_schriftbuero/`.
Der User legt Uploads in `Inbox/` ab.
Der Architekt erstellt Briefings, Fragenkataloge und Initiatoren.
Pattern siehe `_runbooks/schriftbuero-erstellen.md` und `_schriftbuero/README.md`.
```

### 10. Inbox erst-Cleanup planen

Setze in deine Memory eine Notiz: nach 4 Wochen Inbox-Cleanup pruefen
(`Inbox/` → `Inbox/_archiv/<jahr>/`). Dieser Schritt ist nicht akut, aber
gehoert zur langfristigen Hygiene.

## Verifizieren

- [ ] `<Projekt>/_schriftbuero/` existiert mit allen 6 Unterordnern
- [ ] README.md in `_schriftbuero/` und in `_schriftbuero/Inbox/` existieren
- [ ] 5 Templates in `Templates/` vorhanden
- [ ] Erstes Briefing in `Briefings/` liegt vor
- [ ] Erster Initiator in `Kontinuitaet/` liegt vor
- [ ] (Optional) Erster Fragenkatalog in `Fragenkataloge/`
- [ ] `<Projekt>/CLAUDE.md` verweist im Schriftbuero-Sektion auf `_schriftbuero/README.md`
- [ ] Keine Klartext-Credentials, nirgendwo

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Learnings

### Mai 2026 — ProjectEpsilon Schriftbuero
- **Pattern wiederverwendbar.** MultiBrandShops-Schriftbuero und ProjectEpsilon-Schriftbuero
  sind strukturell identisch. Beim dritten Projekt einfach copy-paste-anpassen.
- **Inbox-README ist Pflicht.** Ohne Anleitung wirft der User Files mit
  unklarer Naming-Konvention rein. Mit Anleitung sind die Datei-Namen
  sortier- und auffindbar.
- **Initial-Briefing erst nach Sub-Agenten-Output.** Wenn parallel SDK-Studien
  laufen, lohnt sich, das Briefing erst nach Eingang der Sub-Agenten-Berichte
  zu schreiben — sonst muss man es zweimal schreiben.
- **Ein Briefing pro Welle.** Niemals zwei Themen in einem Briefing mischen
  — der User kann sonst nicht entscheiden welche Aktion zu welcher Frage gehoert.
- **Schriftbuero ersetzt nicht Memory.** Memory ist projekt-uebergreifend,
  Schriftbuero ist projekt-lokal. Manche Sachen gehoeren in beides — z.B.
  Server-Pfad-Aenderungen ins Memory + ins Schriftbuero.
