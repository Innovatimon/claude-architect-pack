# Runbook: Agent-Initialisierung (Session-Setup fuer PA-Architekten + Worker)
> Klassifikation: L2

> **Trigger:** "Initiiere dich", "Session starten", "neuer Agent in PA", "lies dich ein", "wo stehen wir", "uebernimm die Architekten-Rolle"
>
> **Zielbild:** Nach dieser Routine ist der Agent in <5 Minuten voll handlungsfaehig:
> kennt aktuellen Live-Stand, hat die Run-Geschichte im Kopf, weiss welche Wellen laufen,
> welche User-Aktionen ausstehen und welches Runbook fuer welche Aufgabe greift.

---

## Pflicht-Reihenfolge (10 Schritte, alle parallel wo moeglich)

### Schritt 0 — Persona-Aktivierung (1 Sekunde, IMPLICIT meist schon aktiv)
Skill `thinkLikeUser` wird aktiviert (User-Persona-Layer mit Werten/Reflexen/Anti-Patterns/Entscheidungen/Domain). Bei Sub-Agent-Spawnung in dieser Session: `Aktiviere Skill thinkLikeUser sofort. Working Directory: C:\Users\YourUser\.YourWorkspace\.` im Prompt-Prefix mitgeben.

Aus dem System-Reminder: Skill ist meist via `autonomous-execution` schon implizit aktiv — wenn nicht: `Skill: thinkLikeUser` explizit aufrufen. Pfad: `~/.claude/skills/thinkLikeUser/`.

### Schritt 1 — Memory + Workspace-CLAUDE.md (10 Sekunden)
Beides ist im System-Reminder bereits geladen, aber **bewusst nochmal durchgehen**:
- `MEMORY.md` (im System-Reminder) — Pointer auf alle Memory-Files
- `CLAUDE.md` Workspace-Root — Architekt-Modus, alle Projekte, zentrale Referenzen, **7-Ebenen-Klassifikation L1-L7**

**Was du danach wissen musst:**
- User-Email, User-Datum
- 12 Projekte mit Status (ProjectAlpha, ProjectBeta, Workspace-Dashboard, AgentOS, Einkaufshelfer, ProjectGamma, NicheShop, Server, ProjectZeta, ProjectEpsilon, ProjectDelta, MultiBrandShops)
- **Klassifikations-Ebene des aktuellen Projekts** (z.B. PA = L6 unter `Projekte/MultiBrandShops/Shops/PA/`, ProjectDelta = L7 unter `Projekte/ProjectDelta/`, AgentOS = L4 unter `_system/AgentOS/`)
- Memory-Eintraege als Pointer (insb. `project_grv_perfekt_loop_paused.md` fuer PA-Loop-Stand, `reference_workspace_struktur_2026_05_06.md` fuer Workspace-Layout)

### Schritt 2 — INDEX der Runbooks (10 Sekunden)
```
Read _runbooks/INDEX.md
```
Im Kopf: welches Runbook gilt fuer welchen Trigger. **Falls du in diesem Workspace neu bist** (oder die Navigations-Doktrin seit deinem letzten Run geaendert wurde): zusaetzlich `_runbooks/struktur-navigieren.md` ueberfliegen — das ist die Bedienungsanleitung fuer den Workspace (welche Schicht wann, Pipelines, Mitlern-Loop). Routine-Agenten koennen das ueberspringen.

### Schritt 3 — Live-Status pruefen (parallele Bash) — Pflicht
```bash
cd "/c/Users/YourUser/.YourWorkspace/Projekte/MultiBrandShops/Shops/PA/your-app" \
  && git fetch deploy 2>&1 | tail -2 \
  && git log --oneline -5 deploy/master \
  && echo "---LIVE---" \
  && ssh YOUR_SERVER "cat /root/deployments/your-app/.next/BUILD_ID && systemctl status your-app --no-pager | head -3" \
  && echo "---SMOKE---" \
  && ssh YOUR_SERVER "for p in /de /de/home /de/shop /de/diary /de/clubs /de/community /de/membership /de/legal/impressum /de/legal/datenschutz /de/legal/agb /de/legal/barrierefreiheit /sitemap.xml /robots.txt; do echo -n \"\$p: \"; curl -sL -o /dev/null -w '%{http_code}' https://projectalpha.example.com\$p; echo; done"
```

**Was du danach wissen musst:**
- Aktuelle Live BUILD_ID
- Service-Status (active running / failed)
- Letzte 5 Commits + Push-Reihenfolge — **WICHTIG:** Wenn Commits-Hashes nicht deine sind, ist parallel ein Cloud-Task gelaufen (ProjectAlpha Worker 06:00 / ProjectBeta Worker 06:00). Vor naechstem Push immer `git pull deploy master` + `git pull origin master` an passender Stelle.
- **13/13 Top-Routes** geben 200/307 zurueck (NICHT 11 — Smoke umfasst 13 Routes inkl. `/de/home` und `/de/legal/barrierefreiheit`)
- Eventuelle Crashes: `journalctl -u your-app --since '60 minutes ago' --no-pager | grep -iE 'error|crash' | head`

### Schritt 4 — Workspace-Stand-Files lesen (parallel Read)
3 parallele Reads:
- `MASTER-STATE.md` (Workspace-Root, Schnell-Status)
- `OPEN-ITEMS.md` (Workspace-Root, User-Actions + blockierte Wellen)
- `Projekte/MultiBrandShops/Shops/PA/STATUS.md` (Projekt-Status, Loop-Final-Scores, naechster Schritt)

**Was du danach wissen musst:**
- Aktueller Loop-Status (welche Phase live, welche pausiert, welche pending)
- Score-Trajectory (Mobile/Legal/SEO/Vollstaendigkeit)
- 5 Pflicht-Items vor Stripe-Live (siehe USER-ACTIONS-VOR-LIVE-SWITCH.md)
- Welche Worker offen sind (`TaskList` als Cross-Check)

### Schritt 5 — Tasks pruefen
```
TaskList
```

**Was du danach wissen musst:**
- in_progress Tasks (was laeuft gerade)
- pending Tasks die durch BLOCKED-Note (z.B. Usage-Limit) markiert sind
- completed Tasks der letzten Iteration (Kontext)

### Schritt 6 — Letzten Master-Audit-Bericht ueberfliegen (optional bei nicht-trivialer Aufgabe)
```
Glob Projekte/MultiBrandShops/Shops/PA/_archive/*-berichte/MASTER-*FINAL*.md
```
Falls leer:
```
Glob Projekte/MultiBrandShops/Shops/PA/_archive/*-berichte/W-*-final-bericht.md
```
Letztes File lesen (Executive Summary + Score-Trajectory + Verbleibende Tracks).

**Naming-Hinweis:** Welle-Berichte heissen oft `W-<id>-final-bericht.md` (lowercase, mit Bindestrichen) ODER `MASTER-AUDIT-<datum>-FINAL.md`. Glob-Pattern muss flexibel sein.

### Schritt 7 — Aktiv laufende Background-Worker (falls vorhanden)
Bei Notification-Reminders im Kontext: Liste was noch laeuft. Niemals neue Wellen spawnen wenn parallele Worker an gleichen Files arbeiten koennten — siehe `multi-worker-coordination.md`.

### Schritt 8 — User-Antwort (Standard-Format)
```
Initialisiert. Aktueller Stand:
- Live BUILD_ID: <hash> (Service active <X>h)
- Smoke: <N>/<N> Routes 200
- Loop-Phase: <X> (Letzter Worker: <welle> <commit>)
- Tasks: <N> in_progress, <N> pending, <N> completed
- Offene User-Actions: <N> (siehe Projekte/MultiBrandShops/Shops/PA/USER-ACTIONS-VOR-LIVE-SWITCH.md)
- Cleanup-Flags: <N> (siehe Schritt 9, ggf. leer)
- Naechster Schritt-Vorschlag: <konkrete Aktion oder Frage an User>
```

### Schritt 9 — Cleanup-Check (Pflicht, max 30 Sekunden)

Bevor du die Hauptaufgabe annimmst, kurz Stale-State pruefen. Drei Checks:

**9.1 Audit-Files (Welle abgeschlossen?)**
```
Glob **/*.audit.md
```
Pro Treffer: Filesystem-mtime pruefen.
- Aelter als 24h -> Welle nicht ordentlich abgeraeumt. Im Status-Bericht
  als `Cleanup-Flag` markieren ("3 stale audit-files in <pfad>").
- Bei eindeutiger Tot-Datei (Worker abgebrochen, kein offener Task)
  und offensichtlichem Cleanup -> 5-Min-Cleanup direkt anbieten oder
  Skill `cleanup-after-welle` triggern.
- Bei Unklarheit -> nur flaggen, nicht selbst loeschen.

**9.2 STATUS.md-Frische der aktiven Projekte**
```
Read MASTER-STATE.md       # falls vorhanden
# pro aktives Projekt aus Root-CLAUDE.md:
Read <projekt>/STATUS.md   # Datums-Header
```
- STATUS.md aelter als 7 Tage und Projekt-Status "AKTIV" -> Drift-Flag.
- Im Status-Bericht: `STATUS-stale: <projekt> (<datum>)`.

**9.3 MASTER-STATE / OPEN-ITEMS vs STATUS-Drift**
- `MASTER-STATE.md` (Workspace-Root) zeigt Projekt X als "live BUILD Y"?
- `Projekte/<X>/STATUS.md` zeigt aber BUILD Z?
- -> Drift markieren als `Master-Drift: <projekt>`.
- Falls trivial (z.B. nur Datum stale) und Live-Status aus Schritt 3 klar:
  MASTER-STATE.md sofort patchen.

**9.4 SSH-Drift-Check (optional bei Architekt-Init, Pflicht bei "lies dich ein und auditiere")**

Workspace-Doku zeigt nicht alle Drifts. SSH-Audit deckt Sachen auf,
die rein lokal nicht sichtbar sind.

```bash
ssh -o BatchMode=yes YOUR_SERVER "
  echo ===CONTAINER===; docker ps --format '{{.Names}} {{.Status}}' | head -20
  echo ===SYSTEMD===; systemctl is-active your-app agentos-v2 your-app 2>&1
  echo ===GIT-CONFIGS-AUF-LEAKS===; for repo in /opt/agentos /opt/mission-control /root/deployments/your-app; do
    [ -f \$repo/.git/config ] && echo \"--- \$repo ---\" && grep -E 'url.*ghp_|url.*://[^/]+:[^@]+@' \$repo/.git/config 2>&1 || true
  done
"
```

Sucht nach:
- **PAT in URL** (`ghp_…@github.com`) -> Secret-Leak, ACT anlegen
- **Tote Services** in server-config.md gelisteten aber nicht active
- **Veraltete Container** (Image-Tag deprecated, Up >30d ohne Update)

Findings -> Cleanup-Flag in Schritt 8 Antwort + ggf. neuer Q-Eintrag im
Konsolidierungs-Fragenkatalog. Bei Secret-Leak SOFORT ACT-File schreiben.

(Lesson aus Welle 2026-05-11: SSH-Audit zeigte PAT in `/opt/agentos/.git/config` und
admin-dashboard.service tot seit 17.04 — beide Drifts waren in der Workspace-Doku
nicht erkennbar. Siehe Memory `feedback_live_verifikation_pflicht.md`.)

**9.5 Runbook-Mitlern-Check (Pflicht am SESSION-ENDE, hier als Reminder)**

Sobald du in dieser Session ein Runbook genutzt hast: **vor Session-Ende EINE Zeile ins `## Run-Log`** des Runbooks (`| Datum | Agent/Welle | PASS|PARTIAL|FIX|META | Notiz |`, neueste oben, max 8). War ein Schritt falsch → korrigieren + `## Learnings`-Eintrag. Das ist die Mitlern-Pflicht (siehe `struktur-navigieren.md` Sektion 6, `CLAUDE.md` "Navigations-Doktrin"). Ein Runbook ohne gepflegtes Run-Log gilt im `heartbeatWorkspace`-Scan als Drift. Spawnst du Sub-Agenten die ein Runbook nutzen: gib ihnen die Pflicht im Prompt mit.

**Output:** Cleanup-Flags-Zeile im Standard-Antwort-Format Schritt 8.
Vollroutine bei mehreren Flags: Skill `cleanup-after-welle` ausloesen
bevor neue Welle gestartet wird.

---

## Was du NICHT tun sollst beim Initiieren

- **Kein Code-Edit** vor erstem User-Befehl
- **Kein Worker spawnen** ohne expliziten User-Trigger
- **Nicht alles neu lesen** wenn es im Memory steht (Memory ist Cache!)
- **Keine "Vorschau"-Antwort** mit allen Findings — User will erst Status, dann Aufgabe geben
- **Nicht in fremde Projekt-Ordner abdriften** (ProjectDelta/ProjectGamma/etc.) — nur PA-Kontext laden

---

## Schnell-Referenz (Pointer fuer Vertiefung)

| Aufgabe nach Initiierung | Runbook |
|---------------------------|---------|
| **Verstehen wie der Workspace tickt (Schichten/Pipelines/Mitlern)** | **`struktur-navigieren.md`** |
| Bug fixen / Feature bauen | `webdev-shopdev.md` |
| Loop neu starten / Audit | `website-perfektionieren.md` |
| Mehrere Worker parallel | `multi-worker-coordination.md` |
| Migration anwenden | `supabase-migration-anwenden.md` |
| Compliance pruefen | `legal-compliance-checkliste.md` |
| Notion-Notizen abarbeiten | `arbeitsweise-notion.md` |
| Welle starten / orchestrieren | `welle-orchestration.md` |
| Server / MCP / AgentOS | `mcp-status.md`, `agentos-deploy.md`, `server-restart.md`, `admin-dashboard-fix.md` |
| Notion-Webhook | `notion-webhook-setup.md` |
| Cross-Promo Texte | `cross-promo-voice.md` |
| Neues Runbook schreiben / updaten | `runbook-erstellen.md` (+ Vorlage `_control/templates/runbook-template.md`) |

---

## Wichtige Dateien (Memory-Anchor)

### Workspace-Root
- `MASTER-STATE.md` — Schnell-Status aller Projekte (Pflicht-Lese)
- `OPEN-ITEMS.md` — User-Actions + blockierte Wellen
- `CLAUDE.md` — Architekt-Regeln + Projekt-Liste
- `_runbooks/INDEX.md` — Runbook-Schluessel

### ProjectAlpha-Projekt
- `Projekte/MultiBrandShops/Shops/PA/STATUS.md` — Loop-Final-Scores + naechste Schritte
- `Projekte/MultiBrandShops/Shops/PA/USER-ACTIONS-VOR-LIVE-SWITCH.md` — 14 User-Aktionen mit Prioritaet
- `Projekte/MultiBrandShops/Shops/PA/your-app/CLAUDE.md` — Tech-Stack + Regeln
- `Projekte/MultiBrandShops/Shops/PA/your-app/VISION.md` — Was wir bauen
- `Projekte/MultiBrandShops/Shops/PA/your-app/docs/Design.md` — Design-Tokens
- `Projekte/MultiBrandShops/Shops/PA/_legal/` — Backoffice-Templates (AVV/Verfahrensverzeichnis/DSFA/TIA)
- `Projekte/MultiBrandShops/Shops/PA/_archive/<datum>-berichte/MASTER-AUDIT-*-FINAL.md` — letzter Loop-Bericht

### Memory-Files (`C:/Users/YourUser/.claude/projects/.../memory/`)
- `MEMORY.md` — Index aller Memory-Files
- `project_grv_perfekt_loop_paused.md` — V1-Loop-Abschluss + Trigger-Worte
- `reference_grv_*.md` — Infrastruktur, Produkt, DB-State, GCP, Stripe-Niche-Vertical-Risk
- `feedback_*.md` — User-Praeferenzen (Umlaute, Mobile-First, etc.)

---

## Live-Status-Snapshot (zuletzt aktualisiert: PERFEKT-Loop V2 + H1)

> Wenn dieser Snapshot aelter als 3 Tage ist, neu fetchen via Schritt 3.

```
Stand 2026-05-05 nach H1 Lighthouse-Sandbox-Fix:
- BUILD_ID: Y55wgcsU-J7q3qDiQzAWw
- Service: active running
- Smoke: 20/20 Routes 200
- Loop-Final-Scores: Mobile 93+ / Legal 94+ / SEO 88-95 / Vollstaendigkeit 92+
- Phase A-G komplett LIVE (8 Iter, 24 Worker, 26+ Commits)
- 5 Pflicht-User-Actions vor Stripe-Live (AVV/Verfahrensverzeichnis/DSFA/TIA/Live-Switch)
```

---

## Initiierungs-Anti-Patterns

- **NICHT** "ich lese mich erstmal komplett ein" und 30+ Dateien Read'en — INDEX + Memory + Live-Status reicht
- **NICHT** ohne Bash-Status-Check antworten — Live-Stand ist Pflicht-Kontext
- **NICHT** alte BUILD_IDs als aktuell zitieren — IMMER ssh YOUR_SERVER Live-pruefen
- **NICHT** parallel arbeitende Worker uebersehen — Notifications + TaskList pruefen
- **NICHT** dem User antworten "Was soll ich tun?" ohne Status — IMMER Status + Vorschlag

---

## Verifizieren

- [ ] Live BUILD_ID gepruft (frischer Bash-Aufruf)
- [ ] Service-Status verifiziert (active running)
- [ ] Smoke-Routes durch (>= 13 Routes 200)
- [ ] MASTER-STATE.md gelesen
- [ ] OPEN-ITEMS.md gelesen
- [ ] STATUS.md des aktiven Projekts gelesen
- [ ] TaskList ueberprueft (parallele Worker?)
- [ ] User-Antwort enthaelt: BUILD_ID + Smoke + Loop-Phase + Tasks + Naechster-Schritt-Vorschlag
- [ ] Schritt 9 Cleanup-Check durchgefuehrt (Stale-`.audit.md`, STATUS-Frische, Master-Drift)
- [ ] Schritt 9.5: genutzte Runbooks → Run-Log-Zeilen ergaenzt (Mitlern-Pflicht)

---

## Run-Log

| Datum | Agent / Welle | Outcome | Notiz |
|-------|---------------|---------|-------|
| 2026-05-12 | Runbook-Mitlern-Welle | FIX | Schritt 2 (struktur-navigieren-Hinweis) + Schritt 9.5 (Run-Log-Pflicht-Reminder) + Schnell-Referenz-Zeile ergaenzt. |
| 2026-05-11 | Architekt-Init / SSH-Drift-Welle | FIX | Schritt 9.4 SSH-Drift-Check eingefuehrt (PAT-Leak + tote Services entdeckt). |
| 2026-05-05 | PA-Architekt-Init | META | Runbook angelegt — Init als Standard-Routine. |

## Learnings

### 2026-05-05 — Initiierung als Standard-Routine eingefuehrt
Der User hat nach 5+ Sessions an PA gemerkt, dass die Initialisierungs-Routine
sich wiederholt: jedes Mal werden CLAUDE.md, INDEX, MASTER-STATE, OPEN-ITEMS,
STATUS.md gelesen, dann Live-Status via ssh gepruft, dann TaskList. Dieses
Runbook formalisiert die Sequenz, sodass User nur noch "Initiiere dich" sagt.

### Lehre: Memory ist Cache, nicht Wahrheit
Memory-Files koennen aelter als 24h sein. Die Live-BUILD_ID-Pruefung
via ssh ist Pflicht — Memory ist Kontext, nicht Wahrheit. Bei Diskrepanz:
Live-Stand zaehlt, Memory updaten.

### Lehre: 8 Schritte sind das Minimum
Weniger als 8 Schritte fuehrt zu Annahmen-basierten Antworten. Mehr als
12 Schritte ist Overkill — der Agent sollte nach <5 Min handlungsfaehig sein.

### Lehre: Initiierungs-Antwort ist Standard-Format
Nicht improvisieren. Immer 6 Zeilen: BUILD_ID + Smoke + Loop-Phase + Tasks +
Offene User-Actions + Naechster-Schritt-Vorschlag. Der User scannt das in 5
Sekunden und gibt dann den naechsten Befehl.

### 2026-05-11 — SSH-Drift-Check (Schritt 9.4) eingefuehrt
Workspace-Doku alleine zeigt nicht alle Drifts. SSH-Audit bei Init-Welle
zeigte:
- **PAT-Klartext in `/opt/agentos/.git/config`** (`https://YOUR_OLD_GITHUB_USER:ghp_…@github.com/...`).
- **`admin-dashboard.service` disabled/inactive seit 17.04** (in server-config.md
  als aktiv gelistet — Drift).
- **AgentOS-Repo-User-Drift** (Doku sagt `YOUR_GITHUB_USER`, Server-Ist `YOUR_OLD_GITHUB_USER`).

Lesson: Bei Architekt-Init SSH-Drift-Check als Schritt 9.4 ausfuehren.
Bei Secret-Leak SOFORT P0-ACT-File schreiben (siehe ACT-2026-05-11-002).
Memory: `feedback_live_verifikation_pflicht.md`.
