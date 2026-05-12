# MASTER AUDIT: [PREFIX]-[NAME]-[NR] — [Titel]

> **Agent:** Claude Code (YourWorkspace Terminal)
> **Zugang:** [SSH/lokal/beides]
> **Skill:** /mnt/skills/user/audit-worker/SKILL.md
> **Persona-Pflicht:** `Aktiviere Skill thinkLikeUser sofort. Working Directory: C:\Users\YourUser\.YourWorkspace\.` (Pfad: `~/.claude/skills/thinkLikeUser/`) — vor allem anderen!
> **Suffix:** [name].audit.md / [name].handoff.md
> **Datum:** [ISO 8601]
> **Auto Mode:** Ja
> **Agent Teams:** [Ja/Nein — wenn ja, Teammates beschreiben + thinkLikeUser-Prefix in jedem Sub-Prompt]

---

## [MISSION OBJECTIVE]

Am Ende dieses Audits existiert:

1. [Konkrete Ergebnisse auflisten]
2. [Jedes Ergebnis muss pruefbar sein]
3. [Keine vagen Formulierungen]

---

## [PHASEN-EXEKUTION]

### Phase 1: [Titel]

**Ziel:** [Was diese Phase erreicht]

```bash
# Konkrete Befehle
```

- [ ] Schritt 1
- [ ] Schritt 2
- [ ] Schritt 3

### Phase 2: [Titel]

**Ziel:** [Was diese Phase erreicht]

```bash
# Konkrete Befehle
```

- [ ] Schritt 1
- [ ] Schritt 2

### Phase 3: [Titel]

**Ziel:** [Was diese Phase erreicht]

- [ ] Schritt 1
- [ ] Schritt 2

---

## [THE ARCHITECT'S PRIDE]

Qualitaetsansprueche fuer diesen Audit:

- [ ] Zero-Bug-Policy: Build fehlerfrei
- [ ] Kein auskommentierter Code
- [ ] Keine .bak/.old/.orig Dateien
- [ ] Keine verwaisten Dateien
- [ ] [Projekt-spezifische Qualitaetsansprueche]

---

## [THE CRUCIBLE]

Tests die bestehen MUESSEN bevor der Audit als abgeschlossen gilt:

```bash
# Build Test
[build command]

# Lint Test
[lint command]

# Unit Tests
[test command]

# Integration Tests
[test command]
```

- [ ] Build: PASS
- [ ] Lint: PASS
- [ ] Tests: PASS
- [ ] [Manuelle Checks]

---

## [DEPLOYMENT & HANDOFF]

1. Alle Aenderungen committen
2. Deploy: [deploy command]
3. Verify: [verification steps]
4. [suffix].handoff.md ueberschreiben mit Ergebnissen
5. [suffix].audit.md LOESCHEN
