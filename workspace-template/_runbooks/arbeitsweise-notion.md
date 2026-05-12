# Arbeitsweise: Notion-Notizen abarbeiten
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "arbeite nach Arbeitsweise", "Notion abarbeiten", "NXT Run durcharbeiten"

## Schritte

### 1. Notion-Notizen laden
- MCP Tool: `API-post-search` mit Filter `object: page`, Sort `last_edited_time descending`
- Nur Pages aus DB `YOUR_NOTION_DB_ID` (Audit Notizen → Projekte)
- Filtere: Status "Nicht begonnen" = zu bearbeiten, "Nicht beachten" = überspringen
- Lade Block-Children für jede offene Notiz

### 2. Notizen analysieren
- Lies JEDES WORT — User betont das explizit
- Identifiziere: Projekt (aus "Aus" Tag), Typ (Bug/Feature/Recherche), Priorität
- Prüfe vorhandene Agent-Kommentare (Callouts) — was behauptet der Vorgänger?
- User-Korrekturen haben IMMER Vorrang ("NICHT ERLEDIGT!" überschreibt grünes ✅)

#### Projekt-Mapping (Keywords + Aus-Tags)

| Keywords | Projekt | Ordner | Deploy |
|----------|---------|--------|--------|
| Shop, Produkte, Warenkorb, Level, Design, Diary, Community, Clubs, SEO, Supplier | ProjectAlpha | Projekte/MultiBrandShops/Shops/PA/your-app/ | git push deploy master |
| Preisvergleich, Parser, NEM, Supplements | ProjectBeta | SSH: /root/projects/your-project/ | SSH direkt, KEIN git push |
| AgentOS, Telegram, Queue, n8n, Cron | AgentOS | SSH: /opt/agentos/ | SSH direkt, KEIN git push |
| Dashboard, Workspace, Mission-Control, Admin | MissionControl v3 (WorkspaceDashboard deprecated) | _system/AgentOS/agentos/ | siehe VISION-V3.md |
| ProjectZeta, LLM, Ollama, Chatbot, Customer, VoiceAssistant | ProjectZeta / ProjectEpsilon | Projekte/ProjectZeta/ | SSH + Docker |
| ProjectDelta, ProjectDelta, Local-Service-Business | your-app | Projekte/ProjectDelta/ | git push (Server-Hook) |
| Vegan, Rezept, BrandOne | NicheShop | Projekte/MultiBrandShops/Shops/BrandOne/ | Docker / Server |
| Neues Projekt, neue Branche | — | — | Runbook `neues-projekt-erstellen.md` |

**Typ erkennen:**
- Bug: "kaputt", "Fehler", "funktioniert nicht", "crash", "broken"
- Feature: "implementieren", "bauen", "hinzufuegen", "erstellen", "neu"
- Redesign: "Design", "UI", "UX", "umgestalten", "Theme"
- Recherche: "recherchieren", "untersuchen", "pruefen", "analysieren"

**Mehrere Themen?** → AUFTEILEN: 1 Thema = 1 Audit.
**Prioritaet:** Critical > Bugs > Features > Redesign > Recherche.

### 3. Ist-Zustand prüfen (IMMER!)
- Für jedes betroffene Projekt parallel:
  - `git log --oneline -10` (was wurde committed?)
  - `git status` (uncommitted changes?)
  - Server-Stand prüfen via SSH (welcher Commit ist deployed?)
  - Live-Website testen (curl HTTP Status)
- Vergleiche: Was der Agent behauptet vs was tatsächlich da ist
- **Mobile Version IMMER mitprüfen** — wir sind Mobile First

### 4. Agent Team spawnen
- 1 Agent pro unabhängigem Projekt (parallel)
- Abhängige Tasks sequentiell innerhalb eines Agents
- Jeder Agent bekommt:
  - **Pflicht-Header im Prompt:** `Aktiviere Skill thinkLikeUser sofort. Working Directory: C:\Users\YourUser\.YourWorkspace\.` (sonst arbeitet Agent ohne User-Persona/Default-Heuristiken; Skill-Pfad `~/.claude/skills/thinkLikeUser/`)
  - Projekt-Ordner Pfad
  - Konkrete Aufgabenliste (aus Notion-Notizen)
  - Deploy-Anweisungen
  - Build-Pflicht vor Commit (Zero-Bug-Policy)
- Mode: `bypassPermissions` für autonome Arbeit

### 5. Code-Änderungen + Build + Commit
- Jeder Agent: Fix → `npm run build` (0 Errors!) → `git commit`
- Commit-Message beschreibt die Fixes klar

### 6. Deploy
- ProjectAlpha: `git push deploy master` (Hook baut + restartet automatisch)
- Server-Projekte: SSH direkt
- Nach Deploy: Verifizieren (curl + SSH systemctl status)
- **Deployed Code auf Server prüfen** (Dateien stichprobenartig lesen)

### 7. Supabase-Migrationen prüfen
- Lokale Migrationen in supabase/migrations/ mit Live-DB vergleichen
- Falls MCP nicht verfügbar: Dokumentieren welche Migrationen noch applied werden müssen
- Nie blind migrieren — erst prüfen was schon da ist

### 8. Notion-Kommentare schreiben (INLINE!)

**WICHTIG (User-Regel 2026-05-05):**
Notion-Kommentare werden ERST geschrieben wenn:
1. ALLE Worker-Agents fertig sind (run_in_background-Notifications eingegangen)
2. Der Lead/Architekt ALLE Code-Aenderungen abgenommen hat
3. Build EXIT 0 + Live-Verifikation der Aenderungen (BUILD_ID = neu, Routen 200, HTML enthaelt erwartete Strings)
4. Reviewer-Agent (Independent-Sub) hat PASS gegeben

**Nicht waehrend des Runs.** Nicht "Zwischenstand-Updates". Nur am Ende.

Begruendung: Der User will keine optimistischen "✅ erledigt"-Stempel sehen die spaeter zurueckgenommen werden muessen. Erst LIVE = erst Kommentar.

Format der Kommentare:
- **NACH jedem User-Abschnitt** einen farbigen Callout einfügen (`after` Parameter!)
- Farben:
  - 🟢 `green_background` = erledigt (was + wie + Commit)
  - 🟡 `yellow_background` = offen / braucht User-Action
  - 🔵 `blue_background` = Info / Handoff
- Am Ende: HANDOFF-Block mit Datum, Commits, Deploy-Status, nächste Schritte
- **Nie Kommentare am Ende sammeln** — immer direkt nach dem betreffenden Abschnitt

#### Anti-Pattern: Pre-Live-Kommentare
Nicht: "Welle gestartet, ich update spaeter den Stand."
Nicht: "Worker dispatched, Status folgt."
Nicht: optimistisches "✅ erledigt" bevor Live + Reviewer-PASS bestaetigt sind.

Ja: erst nach Live + Reviewer-PASS, dann ALLE Kommentare in einem Rutsch via `after`-Parameter — chronologisch geordnet, ein Callout pro User-Abschnitt.

### 9. Notion-Status aktualisieren
- Name ändern: "NXT Run" → "OLD Run [DATUM]"
  - `API-patch-page` mit properties.Name
- Status ändern: "Nicht begonnen" → "Erledigt"
  - `API-patch-page` mit properties.Statu
- **NUR nach erfolgreichem Deploy + Reviewer-PASS!**

### 10. Abschluss-Bericht
- Im Terminal: Zusammenfassung was pro Projekt gemacht wurde
- Offene Punkte klar benennen (was braucht User-Action)

## Verifizieren
- [ ] Alle Notion-Notizen auf "Erledigt"
- [ ] Alle Notizen umbenannt zu "OLD Run [Datum]"
- [ ] Live-Websites erreichbar und aktuell
- [ ] Inline-Kommentare in jeder Notiz vorhanden (erst NACH Live + Reviewer-PASS!)
- [ ] HANDOFF-Block am Ende jeder Notiz

### 6. Deploy (KRITISCH — lies alles!)

**ProjectAlpha (Next.js auf Server):**
1. `git push deploy master` — Hook baut + restartet automatisch
2. **NACH dem Push: SSH auf Server und verifizieren:**
   ```bash
   ssh YOUR_SERVER "cd /root/deployments/your-app && head -5 src/app/[locale]/(app)/shop/[id]/MagneticBuySection.tsx"
   ```
3. **Browser-Cache ist der Feind.** Next.js 14 setzt `s-maxage=31536000` (1 Jahr!) auf statische Seiten.
   - Fix ist in `next.config.mjs`: Custom headers mit `Cache-Control: no-store, must-revalidate`
   - Falls Seiten trotzdem alt aussehen: `.next/cache/` auf dem Server loeschen + restart
4. **User MUSS Hard Refresh machen** (`Ctrl+Shift+R`) oder Inkognito nutzen nach Deploy

**Post-Receive Hook ProjectDelta:**
- Pfad: `/root/git/your-app.git/hooks/post-receive`
- Hook loescht `.next/cache` vor UND nach dem Build (Schritt 5 + 7 im Hook)
- Hook sichert `.env.local` automatisch vor Checkout und stellt sie wieder her
- Deploy-Log: `/root/deployments/deploy.log`

**Server-Projekte (Admin Dashboard etc.):**
- SSH direkt, Dateien editieren, `systemctl restart <service>`
- Admin Dashboard: `/opt/admin-dashboard/`, Service: `admin-dashboard`, Port 8800

**Nach JEDEM Deploy pruefen:**
```bash
# ProjectAlpha
ssh YOUR_SERVER "curl -sI http://localhost:3002/gate | grep 'Cache-Control'"
# Muss "no-store" zeigen, NICHT "s-maxage=31536000"
# Admin Dashboard
ssh YOUR_SERVER "curl -s https://admin.workspace.example.com/api/auth/status"
```

### 7. Supabase-Migrationen prüfen
- Lokale Migrationen in supabase/migrations/ mit Live-DB vergleichen
- Falls MCP nicht verfügbar: Dokumentieren welche Migrationen noch applied werden müssen
- Nie blind migrieren — erst prüfen was schon da ist

### 8. Notion-Kommentare schreiben (INLINE!) — Detail-Wiederholung

> **Zusammenfassung — Vollform siehe oben.**

**Reihenfolge erzwingen (User-Regel 2026-05-05):**
Worker fertig → Build EXIT 0 → Push → Live-Verifikation (BUILD_ID neu + curl 200 + HTML-Greps) → Independent-Reviewer-PASS → ERST DANN Notion-Kommentare + Status-Update.

- **NACH jedem User-Abschnitt** einen farbigen Callout einfügen (`after` Parameter!) — aber erst nach Live + Reviewer-PASS.
- Farben:
  - 🟢 `green_background` = erledigt (was + wie + Commit)
  - 🟡 `yellow_background` = offen / braucht User-Action
  - 🔵 `blue_background` = Info / Handoff
- Am Ende: HANDOFF-Block mit Datum, Commits, Deploy-Status, nächste Schritte
- **Nie Kommentare am Ende sammeln** — immer direkt nach dem betreffenden Abschnitt
- **Nie waehrend der Welle kommentieren** — keine "im Anflug"-Stempel.

### 9. Notion-Status aktualisieren
- Name ändern: "NXT Run" → "OLD Run [DATUM]"
  - `API-patch-page` mit properties.Name
- Status ändern: "Nicht begonnen" → "Erledigt"
  - `API-patch-page` mit properties.Statu
- **NUR nach erfolgreichem Deploy + Reviewer-PASS!**

### 10. Abschluss-Bericht
- Im Terminal: Zusammenfassung was pro Projekt gemacht wurde
- Offene Punkte klar benennen (was braucht User-Action)

## Notion-Final-Callout-Pattern (Welle-Abschluss bei bereits-erledigten Notizen)

Wenn eine Notiz aus VORIGER Welle schon "Erledigt" ist und neue Welle bringt zusaetzlichen Stand:

- KEINE neuen Inline-Callouts unter User-Bloecken (wuerde alte Story durcheinander bringen)
- EIN Top-Level-Callout an Page-Ende mit `after = null` im PATCH-Body
- Inhalt: BUILD_ID + Routen-Smoke + Worker-Anzahl + Score-Vorhersage + Pre-Live-Block-Status + Next-Step
- emoji 🎯, color `blue_background`
- Format-Vorlage:
  ```
  PERFEKT-Welle X+Y+Z abgeschlossen YYYY-MM-DD - autonom durchgezogen.
  Final-BUILD_ID: <id>. N Routen Smoke: K x 200, M x 404 (branded).
  N Worker, M+ Commits, P DB-Migrations.
  Score-Vorhersage:
  - SEO: ALT -> NEU
  - Mobile: ...
  - Lighthouse: PERF X-Y, A11Y/BP/SEO 100/100/100
  Pre-Live-Block: Code-seitig keine P0 mehr. User-Actions: <Pfad zur Action-Liste>.
  Naechster Schritt-Vorschlag: <konkret>.
  ```

## Verifizieren
- [ ] Alle Notion-Notizen auf "Erledigt"
- [ ] Alle Notizen umbenannt zu "OLD Run [Datum]"
- [ ] Live-Websites erreichbar und aktuell (Hard Refresh!)
- [ ] Inline-Kommentare in jeder Notiz vorhanden — geschrieben **erst nach** Live + Reviewer-PASS
- [ ] HANDOFF-Block am Ende jeder Notiz
- [ ] Cache-Header pruefen: `no-store` statt `s-maxage=31536000`

## Audit-Format (5 Sektionen)

Pro Notiz/Thema ein `[suffix].audit.md` im Projekt-Ordner:

```markdown
# MASTER AUDIT: [ID] — [Titel]
> Agent: Claude Code (im [ordner]/ Ordner oeffnen)
> Suffix: [name].audit.md

## [MISSION OBJECTIVE]
Was am Ende existieren/funktionieren muss. Konkret, messbar.
Kontext aus VISION/STATUS eingebaut.

## [PHASEN-EXEKUTION]
Nummerierte Phasen mit Dateipfaden, Code-Beispielen, Bash-Befehlen.
Bei grossen Features: Agent Teams definieren.

## [THE ARCHITECT'S PRIDE]
Qualitaetsansprueche. Was NICHT akzeptabel ist.

## [THE CRUCIBLE]
Mindestens 3 testbare Bash-Commands die PASS/FAIL zeigen
(Build-Check, Feature-Tests, Route/API-Tests).

## [DEPLOYMENT & HANDOFF]
- Git-Projekte: Commit + Push
- Server-Projekte: Kein Git, Aenderungen sind direkt live
- STATUS.md ueberschreiben
- Audit-Datei loeschen
```

**Qualitaetsregeln:** SPEZIFISCH (Projekt + Thema), CRUCIBLE (>=3 testbare Checks), KONTEXT (VISION/STATUS eingebaut), SERVER (KEIN git push), Agent Teams bei grossen Features.

## MCP-Disconnect-Workaround (Notion-API direkt)

Falls Notion MCP mid-session disconnected:

```bash
# Token vom Server holen
ssh YOUR_SERVER "cat /opt/mcp-gateway/your-notion.json | grep -o 'ntn_[a-zA-Z0-9]*'"

# PATCH Page-Status / Inline-Callout
curl -X PATCH https://api.notion.com/v1/blocks/{page_id}/children \
  -H "Authorization: Bearer ntn_..." \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{"after": "<block_id>", "children": [...]}'
```

Notiz-IDs fuer spaeteres Aufraeumen speichern, am Ende der Welle erneut versuchen.

## Schritt 5 Detail: Agent-Team-Spawn Regeln

- **Worktrees NICHT** im Root-Workspace (`~/.your-workspace` ist kein Git-Repo). Im Projekt-Repo (z.B. your-app) ja.
- **Datei-Grenzen** pro Agent setzen wenn ohne Worktree gearbeitet wird (Merge-Konflikte vermeiden).
- **Agents fuehren KEINEN `npm run build` aus.** Lead macht einen einzigen Build am Ende nach Merge (Windows `.next` Build-Lock).
- **1 Teammate pro Projekt** (alle Audits eines Projekts gebuendelt). Server-Projekte: kein Worktree, SSH direkt.
- **Agent-Prompt muss ALLES enthalten:** Arbeitsverzeichnis, Tech-Stack, Brand-Colors, Build-Befehl, Datei-Grenzen, "kein build hier" — Agents haben keinen Kontext vom Lead.

## Review-Regeln (Schritt 6 Detail)

- ALLES PASS → weiter zu Merge/Deploy
- KLEINER FAIL (<5 min) → Lead fixt selbst
- GROSSER FAIL → Teammate nochmal (max 2 Korrektur-Runden, dann melden)
- BRAUCHT USER-INPUT → "Offene Frage" notieren, NICHT blockieren
- CRUCIBLE Tests NOCHMAL laufen lassen (Lead selbst).

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Learnings

### Deploy-Pipeline (April 2026 — KRITISCH)
- **Next.js Full Route Cache** war das groesste Problem: `.next/cache/` (381 MB) persistierte ueber Deploys und servierte alte Seiten trotz neuem Build. Fix: Hook loescht Cache vor+nach Build, `next.config.mjs` setzt `no-store` Headers.
- **`return null` in Client-Komponenten** kann Features unsichtbar machen ohne Fehlermeldung. Beispiel: `MagneticBuySection` pruefete `shopify_variant_id` und renderte NICHTS wenn es fehlte. Immer pruefen ob Komponenten Daten-Abhaengigkeiten haben die auf dem Live-System nicht erfuellt sind.
- **Server git log ≠ deployed Stand** wenn Deploy per bare-repo Hook laeuft. Der Hook macht `git checkout -f` in das Working Directory, aber `.git/` dort ist ein anderes Repo. Stattdessen Dateien direkt auf dem Server pruefen.
- **Build-Verifikation nach Push:** Nicht nur HTTP Status pruefen, sondern tatsaechlich den HTML-Output und die JS-Chunks auf dem Server lesen. `curl -s http://localhost:3002/page | grep 'erwartetes-element'`
- **BUILD_ID vergleichen:** `cat .next/BUILD_ID` auf Server vs `grep buildId` im HTML-Output der Live-Domain. Wenn identisch: Deploy hat funktioniert, Problem ist Cache.

### Infrastruktur
- Supabase MCP (mcp-server-supabase) ist nicht immer verfuegbar — Migrationen als offenen Punkt dokumentieren
- Admin Dashboard (`/opt/admin-dashboard/`) ist ein separates Python-Projekt, NICHT Teil der Next.js App
- Admin 2FA: TOTP-Eingabefeld war per JS-Toggle versteckt (`class="hidden"`). Wenn async `checkAuthStatus()` fehlschlaegt (Netzwerk, CORS), bleibt es unsichtbar. Fix: Feld standardmaessig sichtbar machen wenn 2FA konfiguriert ist.
- Caddy cached NICHT — es proxied 1:1. Cache-Probleme liegen immer bei Next.js oder dem Browser.

### Arbeitsweise
- Immer ERST den Ist-Zustand pruefen bevor man die Callouts des Vorgaengers glaubt
- Mobile First: Alle UI-Aenderungen auch mobil testen
- Agent-Kommentare in Notion: `after` Parameter nutzen um NACH dem jeweiligen User-Block einzufuegen
- Wenn User sagt "nichts hat sich geaendert" — dem User vertrauen, nicht den eigenen Logs. Tiefer graben: Cache-Headers, JS-Chunks auf Server, tatsaechlicher HTML-Output.

### Agent-Splitting (17.04.2026)
- **Grosse Notizen NICHT als 1 Mega-Agent abarbeiten.** Erst analysieren, unabhaengige Teilaufgaben identifizieren, dann 1 Agent pro Teilaufgabe spawnen. Beispiel: ProjectAlpha-Notiz mit 7 Bereichen → 4 spezialisierte Agents (PDP+Gear, Community, Diaries, AI+Bugs) statt 1 der alles sequentiell macht.
- **Datei-Grenzen definieren:** Jedem Agent mitteilen welche Verzeichnisse er NICHT anfassen darf (andere Agents arbeiten daran). Verhindert Merge-Konflikte.
- **Worktree-Isolation nur in Git-Repos moeglich.** Root-Workspace `.YourWorkspace/` ist kein Git-Repo → Agents ohne Worktree spawnen, dafuer Datei-Grenzen setzen.

### N8N Workflows (17.04.2026)
- **N8N API auf Server ausfuehren**, nicht lokal. `ssh YOUR_SERVER "curl -s -H 'X-N8N-API-KEY: ...' http://localhost:5678/api/v1/..."`. Dateien die auf dem Server in /tmp/ landen, koennen nicht lokal gelesen werden.
- **Resend SMTP**: Domain muss verifiziert sein. `supplier@projectalpha.example.com` funktioniert (projectalpha.example.com ist verifiziert), `supplier@workspace.example.com` NICHT (nicht verifiziert).
- **N8N Tags** koennen per Public API erstellt aber NICHT Workflows zugewiesen werden → manuell in UI.

### Supabase / Diaries (17.04.2026)
- **Storage Bucket-Name pruefen:** Code nutzte `"images"` aber Bucket heisst `"user_content"`. Immer tatsaechlichen Bucket-Namen aus Supabase Dashboard verifizieren.
- **RLS Policies nicht auf Live:** Migrationen 010-022 existierten nur lokal. SQL-Script `fix-diary-rls.sql` als idempotentes All-in-One erstellt.
- **getUserTier() war hardcoded:** Gab immer "pro" zurueck → alle User hatten Pro-Features. Fix: async aus `profiles.subscription_tier` lesen.
- **Infinite Loading:** `fetchPosts` warf unhandled Error → `isLoading` blieb `true`. Fix: try/catch + `.finally()` garantiert Reset.
