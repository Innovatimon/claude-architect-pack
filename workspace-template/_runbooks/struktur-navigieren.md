# Runbook: Struktur navigieren — wie nutze ich Runbooks, Skills, CLAUDE.md, Memory & Co.?
> Klassifikation: L2 (Global, gilt fuer alle Projekttypen + alle Agenten)
> Stand: 2026-05-12

> **Trigger:** "wie funktioniert das System", "was nutze ich wann", "Runbook oder Skill", "wohin gehoert das", "wie lerne ich mit", "Arbeitsweise erklaeren", "wie arbeite ich in diesem Workspace", "neuer Agent — wie navigiere ich hier", "wo dokumentiere ich das" — und implizit IMMER, wenn unklar ist welche Struktur fuer eine Aufgabe zustaendig ist.

> **Diese Datei ist die Bedienungsanleitung fuer den Workspace selbst.** Sie steht ueber den einzelnen Runbooks: sie sagt dir nicht *wie man X deployt*, sondern *welche unserer Strukturen du fuer X anfasst, wann du eine neue anlegst, und wie das System ueber Zeit besser wird*. Wenn du neu in diesem Workspace bist und schon `CLAUDE.md` gelesen hast: lies das hier als zweites. Voller Doktrin-Kontext: `CLAUDE.md` Sektion "Navigations-Doktrin" + `VISION.md` Sektion 3 (L1-L7).

---

## 1. Die sechs Schichten — wer haelt welches Wissen?

Der Workspace ist kein Haufen Markdown. Er hat sechs klar getrennte Schichten. Jede hat einen Zweck, einen Lade-Zeitpunkt und eine Schreib-Regel. Wenn du weisst welche Schicht zustaendig ist, sparst du dir Suchen *und* du legst neues Wissen am richtigen Ort ab (statt fuenfmal dasselbe an fuenf Stellen).

| Schicht | Wo | Was drin steht | Wann GELADEN | Wann du REINSCHREIBST |
|---------|-----|----------------|--------------|------------------------|
| **1. CLAUDE.md** (L1) | `CLAUDE.md` (Root) + `<Projekt>/CLAUDE.md` | Hard-Rules die *immer* gelten, Top-Doktrin, Projekt-Liste, L1-L7-Hierarchie, zentrale Referenz-Pointer | **Automatisch, immer im Kontext** | Eine Regel aendert sich die fuer alles/dieses Projekt gilt. Sparsam — CLAUDE.md ist teuer (jeder Token in jedem Turn). |
| **2. Memory** | `~/.claude/projects/.../memory/*.md` + `MEMORY.md` (Index) | Wer ist der User (speist `thinkLikeUser`), Feedback/Korrekturen, Projekt-State der nicht im Code steht, externe Refs (URLs, Tickets) | **Index immer im Kontext; Einzel-Files auf Abruf** | Ein nicht-offensichtlicher Fakt der Sessions ueberdauert. NICHT was der Code/Git/CLAUDE.md schon sagt. Frontmatter `type: user\|feedback\|project\|reference`. |
| **3. Runbooks** (L2/L5/L6/L7) | `_runbooks/*.md` (global) + `Projekte/<...>/_runbooks/` (spezifisch), Einstieg: `_runbooks/INDEX.md` | Schritt-fuer-Schritt copy-paste-Prozesse fuer wiederkehrende Aufgaben. Plus `## Run-Log` + `## Learnings` (die Mitlern-Schicht) | **Auf Abruf** — Agent liest INDEX bei jeder Aufgabe, dann das passende Runbook | Eine Aufgabe taucht zum **zweiten Mal** auf. Oder eine Falle in die jeder reinrennt. → `runbook-erstellen.md` |
| **4. Skills** | `~/.claude/skills/<name>/` (SKILL.md + eval.json + learnings.md + last-output.md + context/handoff.md) | Personas + mehrstufige Orchestrierung + Lern-Files + Inter-Skill-Chaining. Das "Gehirn", das mehrere Runbooks/Tools zu einem Workflow verschaltet | **Trigger-aktiviert** (Trigger-Phrase aus `description:`) oder explizit via `Skill`-Tool | Ein Workflow braucht eine *Persona* + *gewichtete Eval* + *Run-Lernen* + *Verkettung mit anderen Skills*. Standard: `~/.claude/skills/` Pflicht-Files (siehe CLAUDE.md "Skill-Standard"). |
| **5. Schriftbuero** | `_schriftbuero/` (global) + `Projekte/<...>/_schriftbuero/` | Mensch↔Agent-Kommunikation: `Briefings/` (Agent→User Was-hat-sich-geaendert), `User-Anleitungen/ACT-*.md` (Agent→User Tu-das), `Inbox/` (User→Agent Uploads), `Fragenkataloge/` + `Antworten/`, `Kontinuitaet/` (Session-Uebergabe) | **Auf Abruf** — wenn der User einen Upload erwaehnt, eine Welle endet, oder eine Session uebergeben wird | Du wirst BLOCKED (→ `ACT-*.md`), eine Welle endet (→ `Briefings/`), oder du uebergibst (→ `Kontinuitaet/`). Skill-Pendant: `_runbooks/schriftbuero-erstellen.md` |
| **6. Projekt-Doku** (L4-L7) | `<Projekt>/{STATUS,VISION,PROJECT,SETUP}.md`, `_control/projects/<name>.md`, `_control/projects/<name>/context/` (Brand), `_control/projects/<name>/data_map.html` | Wo steht dieses Projekt (STATUS), wo will es hin (VISION), was ist es (PROJECT), wie setze ich es auf (SETUP), Brand-Voice (context/), Datenfluss (data_map) | **Auf Abruf** — wenn du an dem Projekt arbeitest | Nach **jeder** Welle: STATUS.md **ueberschreiben** (kein Append). VISION nur bei Strategie-Aenderung. |

**Faustregeln fuer die Schicht-Wahl:**
- *Gilt es immer, ueberall?* → CLAUDE.md. *Gilt es immer, aber ist ein Fakt statt einer Regel?* → Memory.
- *Ist es ein wiederholbarer Ablauf?* → Runbook. *Braucht der Ablauf eine Persona + Lern-Schleife + Verkettung?* → Skill.
- *Im Zweifel spezifischer als globaler.* Ein verirrtes Shop-Runbook in `_runbooks/` liest der ProjectDelta-Agent und halluziniert Shop-Konzepte.
- *Bestehendes erweitern statt duplizieren.* Drei Stellen mit demselben Wissen = drei Stellen die divergieren.

---

## 2. Entscheidungsbaum A — "Ich habe eine Aufgabe. Was nutze ich?"

```
User gibt dir eine Aufgabe / einen Trigger-Satz
   │
   ├─ Ist es Session-Start? ("Initiiere dich" / "wo stehen wir" / "lies dich ein")
   │     → PFLICHT-RUNBOOK: agent-initialisierung.md (10 Schritte). Nichts anderes vorher.
   │
   ├─ NEIN → Erste Aktion IMMER: _runbooks/INDEX.md lesen. Passt ein Runbook? (Trigger-Woerter matchen)
   │     │
   │     ├─ JA → Runbook oeffnen, Schritte ausfuehren, ## Verifizieren abhaken,
   │     │        am Ende ## Run-Log-Zeile ergaenzen (PASS/PARTIAL/FIX). Fertig.
   │     │
   │     └─ NEIN → ist es eine der grossen Orchestrierungs-Aufgaben? Dann Skill-Chain:
   │           ├─ "Notion abarbeiten" / "Orchestrator" / "Lies Notion und arbeite alles ab"
   │           │     → thinkLikeUser → audit-creator → audit-worker → cleanup-after-welle
   │           ├─ "neues Projekt bootstrappen" / "/silver-platter"
   │           │     → thinkLikeUser → bootstrapNewProject → generateProjectDataMap → (audit-creator → audit-worker → cleanup)
   │           ├─ "Website perfekt machen" / "Welle PERFEKT" / "alle Bugs raus" / "live gehen"
   │           │     → thinkLikeUser → Runbook website-perfektionieren.md (4-Teams-Audit) → Reviewer → cleanup-after-welle
   │           ├─ "Welle starten" / "iteriere bis perfekt" / "alle Tasks abarbeiten"
   │           │     → Runbook welle-orchestration.md (+ multi-worker-coordination.md bei parallelen Workern)
   │           ├─ "Heartbeat Check" / "Workspace-Drift pruefen" / "welche Audits liegen rum"
   │           │     → Skill heartbeatWorkspace (+ Runbook heartbeat-workspace.md)
   │           ├─ "PA Bugs abarbeiten" / "Findings durchgehen" / "neuer Screenshot im Schriftbuero"
   │           │     → Runbook grv-bugs-workflow.md
   │           └─ keine passt → Aufgabe trotzdem loesen (autonom, Architekt-Default).
   │                            DANACH: Pattern erkannt das sich wiederholt? → Runbook erstellen (runbook-erstellen.md).
   │                            Einmaliges? → nichts dokumentieren, fertig.
   │
   └─ Bei JEDER Aufgabe in diesem Workspace implizit aktiv: thinkLikeUser (User-Persona).
      Bei JEDER Sub-Agent-Spawnung: "Aktiviere Skill thinkLikeUser sofort. Working Directory: ..." im Sub-Prompt-Prefix.
```

**Wichtig:** "Ich lese mich erstmal komplett ein" und 30 Dateien Read'en ist ein Anti-Pattern. INDEX + Memory-Index + (bei Architekt-Init) Live-Status reicht. Memory ist Cache, nicht Wahrheit — bei Diskrepanz zaehlt der Live-Stand.

---

## 3. Entscheidungsbaum B — "Ich habe was gelernt / einen Prozess entwickelt. Wohin damit?"

Der User sagt oft nur "Skill: X" oder "merk dir das" — *du* entscheidest die Schicht. (Originaltabelle: CLAUDE.md "Skill-Konvention", hier mit Mitlern-Hinweis erweitert.)

| Was du in der Hand hast | Wohin | Wie es danach mitlernt |
|--------------------------|-------|------------------------|
| Globale Doktrin / Workflow ueber alle Projekte | `~/.claude/skills/<name>/SKILL.md` (+ eval.json, learnings.md, last-output.md, context/handoff.md) | `learnings.md` nach jedem Run, `last-output.md` als Referenz, Eval-Score |
| Wiederkehrender Schritt-Prozess, copy-paste-ready | `_runbooks/<name>.md` (Vorlage: `_control/templates/runbook-template.md`) + INDEX-Eintrag | `## Run-Log`-Zeile bei jeder Nutzung, `## Learnings` bei Erkenntnissen |
| Hard-Rule die *immer* gilt | `CLAUDE.md` (Root oder Projekt) | wird bei Bedarf ueberarbeitet — kein eigener Lern-Mechanismus, dafuer immer geladen |
| Nicht-offensichtlicher Fakt der Sessions ueberdauert (User-Profil, Projekt-State, externe Ref) | Memory `~/.claude/.../memory/<typ>_<name>.md` + Pointer in `MEMORY.md` | `cleanup-after-welle` / `memory-pflege.md` halten es frisch; veraltete loeschen |
| User-Feedback / Korrektur ("nein, so nicht") | Memory `feedback_*.md` **und** (falls Persona-relevant) `~/.claude/skills/thinkLikeUser/context/*.md` erweitern | thinkLikeUser-Persona wird damit lebendig — Agent fragt nicht mehr, entscheidet wie der User |
| Eine konkrete Schritt-Anleitung fuer den *Menschen* (Stop-Punkt) | `_schriftbuero/User-Anleitungen/ACT-YYYY-MM-DD-NNN-<topic>.md` + Verlinkung in MASTER-ACTIONS | wird "Erledigt"-markiert nach User-Bestaetigung; Folge-Wuensche → neue ACT |
| "Was hat sich in dieser Welle geaendert" fuer den User | `_schriftbuero/Briefings/YYYY-MM-DD-<welle>.md` | bleibt; `cleanup-after-welle` behaelt die letzten 3 in `Briefings/` |
| Brand-Voice / Positioning / ICP / Marketing-Samples | `_control/projects/<name>/context/{voice,positioning,icp,samples}.md` | Sub-Agenten lesen nur diesen Folder statt 4 Files zu parsen |
| Projekt-Datenfluss-Visualisierung | `_control/projects/<name>/data_map.html` (Skill `generateProjectDataMap`) | wird bei groesseren Pipeline-Aenderungen neu generiert |
| Wo-stehen-wir / Was-kaputt / Naechster-Schritt eines Projekts | `<Projekt>/STATUS.md` (ueberschreiben!) | nach jeder Welle Pflicht-Output von `audit-worker` / `cleanup-after-welle` |

**Im Zweifel: spezifischer (Runbook < projektspezifisches Runbook < CLAUDE.md-Projekt-Sektion) statt globaler. Und: erweitere ein bestehendes File, statt ein neues anzulegen.**

---

## 4. Entscheidungsbaum C — "Etwas Bestehendes stimmt nicht mehr. Was tue ich?"

**Niemals drumherum arbeiten. Fixen.** Der naechste Agent verlaesst sich darauf.

| Fund | Aktion |
|------|--------|
| Runbook-Schritt stimmt nicht (Pfad/Tool/API geaendert, Falle nicht dokumentiert) | Schritt **sofort** korrigieren + `## Run-Log`-Zeile `FIX` + `## Learnings`-Eintrag (`### YYYY-MM — Was war kaputt, was hilft jetzt`). Erst dann eigentliche Aufgabe weiter. |
| Runbook nicht mehr im INDEX / falsche L-Klasse / Trigger trifft nicht | INDEX-Eintrag + Header korrigieren. Ein Runbook ausserhalb des INDEX existiert effektiv nicht. |
| CLAUDE.md-Regel falsch/ueberholt | Regel korrigieren. Im Commit/Bericht erwaehnen warum (es ist L1, andere verlassen sich darauf). |
| Memory-Eintrag veraltet/falsch | Updaten oder loeschen (`memory-pflege.md`). MEMORY.md-Pointer syncen. Phantome (Index ohne File) + Waisen (File ohne Index) bereinigen. |
| Skill-Drift (SKILL.md beschreibt was nicht mehr stimmt; Lern-Files fehlen) | SKILL.md fixen, fehlende `eval.json`/`learnings.md`/`last-output.md`/`context/handoff.md` anlegen. `learnings.md` mit Anti-Pattern fuettern. |
| STATUS.md zeigt was anderes als der Live-Stand | Live-Stand gewinnt. STATUS.md ueberschreiben. MASTER-STATE/OPEN-ITEMS syncen. Drift im Bericht erwaehnen. |
| Phantom-User-Anleitung (ACT-* ohne Index-Eintrag, oder Index zeigt auf geloeschtes ACT) | `schriftbuero-konsolidieren.md` — Phantom-Refs streichen, Folge-Wuensche aus alten ACTs in neue ueberfuehren. |
| Server-/Service-Drift (Doku sagt aktiv, ist tot; PAT im git-config; Container deprecated) | Bei Secret-Leak SOFORT P0-`ACT-*.md`. Sonst: Cleanup-Flag in den Status-Bericht + ggf. Q-Eintrag im Konsolidierungs-Fragenkatalog. Quelle: Memory `feedback_live_verifikation_pflicht.md`. |

Wer ein Runbook/Skill/Memory-File nur *liest*, hat trotzdem die Pflicht es zu verbessern, wenn ihm etwas auffaellt.

---

## 5. Die Standard-Pipelines (die "Arbeitsweise" als Ketten)

Jede grosse Aufgabe ist eine Kette aus `thinkLikeUser` (Persona-Basis) + Skills + Runbooks. Die wichtigsten:

| Pipeline | Trigger | Kette | Output |
|----------|---------|-------|--------|
| **Architekt-Init** | "Initiiere dich" | `agent-initialisierung.md` (10 Schritte: Persona → Memory/CLAUDE → INDEX → Live-Status ssh+curl → MASTER-STATE/OPEN-ITEMS/STATUS → TaskList → letzter Master-Audit → Background-Worker → Standard-Status-Antwort → Cleanup-Check) | Status-Antwort: BUILD_ID + Smoke + Loop-Phase + Tasks + offene User-Actions + Naechster-Schritt-Vorschlag |
| **Notion-Welle** | "Lies Notion und arbeite alles ab" / "Orchestrator starten" | `thinkLikeUser` → `audit-creator` (= `generateAuditsFromNotion`) → `audit-worker` (= `executeAudit`) je Projekt → Reviewer → `cleanup-after-welle` (= `cleanupAfterWelle`) | Live-Features + STATUS.md-Updates + Notion-Kommentare (ERST nach Live + Reviewer-PASS) |
| **Bootstrap-Welle** | "neues Projekt bootstrappen" / "/silver-platter" | `thinkLikeUser` → `bootstrapNewProject` (8-Frage-Interview) → `generateProjectDataMap` → optional `audit-creator` → `audit-worker` → `cleanup-after-welle` | 5 Pflicht-Files mit Inhalt + Brand-Context-Folder + erstes Runbook + data_map.html + CLAUDE.md-Eintrag |
| **Website-PERFEKT** | "live gehen" / "alle Bugs raus" / "Welle PERFEKT" | `thinkLikeUser` → `website-perfektionieren.md` (4-Teams-Audit: Mobile/Legal/SEO/Vollstaendigkeit) → Worker je Track → Reviewer → ggf. Hotfix → `cleanup-after-welle` | 0 P0/P1, Final-Scores, deployt + live-verifiziert |
| **Web/Shop-Aenderung** | "Bug fixen" / "Feature bauen" / "Shop anpassen" | `thinkLikeUser` → `webdev-shopdev.md` (lokal aendern → build → deploy via git push deploy → curl/BUILD_ID-Verify) | Live-Feature + STATUS.md |
| **Wartungs-Loop (Cron)** | alle 6h via `/schedule` | `thinkLikeUser` → `heartbeatWorkspace` → bei Drift: `cleanup-after-welle` oder `memory-pflege.md` oder `schriftbuero-konsolidieren.md` | Heartbeat-Bericht in `_schriftbuero/Heartbeat/<datum>.md` + Auto-Fix-Vorschlaege |
| **Cleanup nach Welle** | "Welle abgeschlossen" / automatisch nach jeder Architekt-Welle | `cleanup-after-welle` (8 Schritte: STATUS ueberschreiben → Audit-Files weg → Tot-Files ins Archiv → Memory pflegen → Schriftbuero-Inbox → MASTER-STATE/OPEN-ITEMS syncen → git status → Kurz-Bericht) | sauberer Workspace, naechster Architekt kann sofort weiter |

**Basis-Layer aller Ketten ist `thinkLikeUser`.** Jeder Sub-Agent-Prompt beginnt mit "Aktiviere Skill thinkLikeUser sofort." — sonst geht die User-Persona beim Delegieren verloren und der Sub-Agent fragt statt zu entscheiden.

---

## 6. Der Mitlern-Loop — *warum* das System ueber Zeit besser wird

Das hier ist der eigentliche Punkt. Strukturen die nicht mitlernen, veralten und werden ignoriert. Jede Schicht hat einen Lern-Mechanismus — der greift aber nur, wenn der **Schreib-Moment erzwungen** ist:

| Schicht | Lern-Artefakt | Erzwungener Schreib-Moment |
|---------|---------------|----------------------------|
| **Runbook** | `## Run-Log` (1 Zeile/Nutzung, max 8) + `## Learnings` (date-stamped) | **Bei jeder Nutzung** Run-Log-Zeile. Bei Erkenntnis: Learnings. Verankert in `agent-initialisierung.md` (Post-Task-Schritt), `audit-worker`/`cleanup-after-welle` (Sub-Agenten-Pflicht), Stop-Hook (Reminder), `heartbeatWorkspace` (Drift-Scan: Run-Log-Top > 30 Tage bei aktivem Bereich = Flag). |
| **Skill** | `learnings.md` (Was funktioniert / Anti-Patterns / Optimierungs-Hypothesen / Run-History) + `last-output.md` (Referenz-Output) + `eval.json` (gewichtete Eval, PASS≥0.85) | Nach jedem Skill-Run: learnings.md + last-output.md updaten, Eval-Score notieren. Bei Major-Update: Run-History-Eintrag mit Score. |
| **CLAUDE.md** | — (kein eigener Loop, dafuer immer geladen) | Wird ueberarbeitet wenn eine Regel sich aendert. Drift faellt im Workspace-Audit auf. |
| **Memory** | Frische via Stale-Marker / Loeschen | `cleanup-after-welle` Schritt 4 + `memory-pflege.md`. `heartbeatWorkspace` Scan 3 erkennt Phantome/Waisen. User-Korrektur → sofort Memory + thinkLikeUser-context updaten. |
| **thinkLikeUser** | `context/*.md` (doktrin/reflexe/anti-patterns/entscheidungen/domain/handoff) + `learnings.md` mit Eval-Score | User korrigiert oder bestaetigt einen nicht-offensichtlichen Pfad → Memory `feedback_*` + context-File erweitern. Bei Major-Update: Run-History in learnings.md. |
| **Projekt-STATUS.md** | wird ueberschrieben | Pflicht-Output am Ende **jeder** Welle (`audit-worker` / `cleanup-after-welle`). Git-Log ist das Archiv. |

**Konkret heisst "Runbooks lernen interaktiv mit" jetzt:** Du nutzt ein Runbook → vor Session-Ende ergaenzt du eine Run-Log-Zeile (`PASS` wenn glatt, `PARTIAL`+Notiz wenn was anders war, `FIX` wenn du was korrigiert hast). Hat dich was ueberrascht → zusaetzlich ein Learnings-Eintrag. Das kostet 10 Sekunden, ist aber der Unterschied zwischen einem Runbook das mit der Realitaet mitwaechst und einem das nach drei Monaten keiner mehr anfasst. Frueher fehlte dieser erzwungene Moment — *deshalb* hat das Mitlernen "in der Regel nicht so gut funktioniert". Jetzt ist er an vier Stellen verankert (Init-Runbook, Worker-Skills, Stop-Hook, Heartbeat).

---

## 7. Anti-Patterns (was du in diesem Workspace NICHT tust)

- **Explorieren statt INDEX lesen.** Erste Aktion bei jeder Aufgabe: `_runbooks/INDEX.md`. Nicht `grep`/`find`/"ich schau mal".
- **Einen Workflow in einen einzelnen Agenten bauen statt in ein Runbook.** Sobald ein Ablauf das zweite Mal auftaucht → Runbook. Sonst kennt ihn nur dieser eine Agent.
- **Eine neue Schicht anlegen wo eine bestehende gepasst haette.** Drei Stellen mit demselben Wissen divergieren garantiert. Erweitere.
- **Eine ambiente Regel als Skill anlegen.** Skills sind trigger-aktiviert — wenn das Wissen *immer* gelten soll, gehoert es in CLAUDE.md (immer geladen), nicht in einen Skill der nur bei einem Stichwort feuert.
- **Ein globales Runbook fuer was Projekt-Spezifisches.** L7-Agenten (ProjectDelta, ProjectZeta, ProjectGamma, ProjectTheta) lesen `_runbooks/` und halluzinieren Shop-/Framework-Konzepte. Im Zweifel `Projekte/<...>/_runbooks/`.
- **Session beenden ohne Run-Log-Zeile**, wenn du ein Runbook genutzt hast. Das ist die Mitlern-Pflicht — kein "mach ich spaeter".
- **Drumherum arbeiten** wenn ein Runbook/Skill/Memory-File falsch ist. Fixen, dann weiter.
- **STATUS.md anhaengen statt ueberschreiben.** Git-Log ist das Archiv. STATUS.md ist immer der *aktuelle* Stand.
- **Sub-Agenten spawnen ohne `Aktiviere Skill thinkLikeUser sofort.` im Prompt-Prefix** — und ohne ihnen die Runbook-Mitlern-Pflicht mitzugeben, wenn sie ein Runbook nutzen sollen.
- **Memory als Wahrheit behandeln.** Memory ist Cache. Bei Diskrepanz mit dem Live-Stand: Live gewinnt, Memory updaten.
- **HANDOFF.md / SESSION-*.md / HOLDING_*.md / CURRENT-AUDIT.md anlegen.** Verboten. STATUS.md + git-Log + (bei Bedarf) `_schriftbuero/Kontinuitaet/` ersetzen das.

---

## 8. Schnell-Referenz — "Ich will X" → "lies/nutze Y"

| Ich will... | → |
|-------------|---|
| ...wissen wo wir stehen / Session starten | `agent-initialisierung.md` |
| ...wissen welches Runbook fuer eine Aufgabe gilt | `_runbooks/INDEX.md` |
| ...ein neues Runbook schreiben / eins updaten | `runbook-erstellen.md` (+ Vorlage `_control/templates/runbook-template.md`) |
| ...wissen wohin neues Wissen gehoert | dieses Runbook, Sektion 3 |
| ...ein neues Projekt aufsetzen | Skill `bootstrapNewProject` (Interview) bzw. `neues-projekt-erstellen.md` / `project-setup` (Skelett) |
| ...Notion abarbeiten / orchestrieren | `arbeitsweise-notion.md` + Skill `audit-creator` |
| ...eine Welle fahren / iterieren bis perfekt | `welle-orchestration.md` (+ `multi-worker-coordination.md`, `website-perfektionieren.md`) |
| ...nach einer Welle aufraeumen | Skill `cleanup-after-welle` (ruft `schriftbuero-konsolidieren.md` + `memory-pflege.md`) |
| ...Workspace-Drift pruefen | Skill `heartbeatWorkspace` + `heartbeat-workspace.md` |
| ...eine Website fixen/deployen | `webdev-shopdev.md` |
| ...eine Website pre-live perfektionieren | `website-perfektionieren.md` |
| ...eine Supabase-Migration anwenden | `supabase-migration-anwenden.md` |
| ...Compliance pruefen | `legal-compliance-checkliste.md` |
| ...Server/MCP/AgentOS anfassen | `mcp-status.md`, `mcp-register-server.md`, `agentos-deploy.md`, `server-restart.md`, `admin-dashboard-fix.md`, `notion-webhook-setup.md` |
| ...einen Menschen ins Projekt holen / zu zweit arbeiten | `team-onboarding.md`, `pair-coordination.md` |
| ...ein Schriftbuero anlegen / konsolidieren | `schriftbuero-erstellen.md`, `schriftbuero-konsolidieren.md` |
| ...Memory pflegen | `memory-pflege.md` |
| ...File-Permission-Probleme unter Windows loesen | `file-operations-windows.md` |
| ...die L1-L7-Hierarchie verstehen | `CLAUDE.md` "Klassifikations-Hierarchie" + `VISION.md` Sektion 3 |
| ...die Top-Doktrin (vollautonom / Umlaute / Skill-Konvention) nachlesen | `CLAUDE.md` (oben) + Skill `autonomous-execution` |
| ...wie der User denkt (Persona) | Skill `thinkLikeUser` (`context/*.md`) |

---

## Verifizieren (nach Aenderungen an diesem Runbook)

- [ ] Die sechs Schichten sind vollstaendig (CLAUDE.md / Memory / Runbooks / Skills / Schriftbuero / Projekt-Doku)
- [ ] Entscheidungsbaeume A/B/C sind konsistent mit `CLAUDE.md` (Skill-Konvention, Klassifikations-Hierarchie) und `runbook-erstellen.md` (Pflicht-Sektionen, Mitlern-Pflicht)
- [ ] Standard-Pipelines stimmen mit den realen Skill-Namen + Runbook-Dateien ueberein (Glob `~/.claude/skills/` + `_runbooks/`)
- [ ] In `_runbooks/INDEX.md` eingetragen + in `CLAUDE.md` "Navigations-Doktrin" verlinkt
- [ ] Keine Credentials, nur Pfade. ASCII (interne Agent-Doku).

## Run-Log

| Datum | Agent / Welle | Outcome | Notiz |
|-------|---------------|---------|-------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | Runbook angelegt — Top-Level-Navigations-Prozess, 8 Sektionen. Begleitet Run-Log-Pflicht-Einfuehrung in allen Runbooks. |

## Learnings

### 2026-05 — Warum dieses Runbook noetig wurde
Der Workspace hatte viele wichtige Runbooks + Skills, aber keinen Ort der erklaert *wie sie zusammenspielen* und *was man wann nutzt*. Neue Agenten (und Sub-Agenten) mussten sich das aus CLAUDE.md + INDEX + verstreuten Sektionen zusammenreimen. Folge: Skills/Runbooks wurden unterbenutzt, Wissen mehrfach abgelegt, Mitlernen blieb aus. Fix: ein L2-Runbook ueber den Runbooks, plus eine kompakte "Navigations-Doktrin"-Sektion in CLAUDE.md die hierher zeigt. Lehre: Ein wachsendes System braucht eine Bedienungsanleitung fuer sich selbst — sonst skaliert es nicht mit der Anzahl der Bausteine.

## Related
- `CLAUDE.md` (Root) — Sektion "Navigations-Doktrin" (kompakte Version), "Skill-Konvention", "Klassifikations-Hierarchie", Top-Doktrin
- `VISION.md` — Sektion 3 (L1-L7-Hierarchie, Begruendung)
- `_runbooks/INDEX.md` — der konkrete Runbook-Schluessel
- `_runbooks/runbook-erstellen.md` — Pflicht-Sektionen + Mitlern-Pflicht + Qualitaets-Rubrik
- `_runbooks/agent-initialisierung.md` — die Session-Start-Pipeline
- `_control/templates/runbook-template.md` — Runbook-Skelett
- Skills: `autonomous-execution`, `thinkLikeUser`, `audit-creator`, `audit-worker`, `cleanup-after-welle`, `bootstrapNewProject`, `generateProjectDataMap`, `heartbeatWorkspace`
