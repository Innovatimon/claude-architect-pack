# _user-overrides/

Dieses Verzeichnis ist **dein** Spielfeld. Updates aus
`claude-architect-pack` werden hier **nie** schreiben oder loeschen.

## Wofuer

- Sub-Files die `CLAUDE.user.md` zu lang machen wuerden
- Persoenliche Runbooks die nicht in `_runbooks/custom-*.md` passen
- Templates die nur du nutzt
- Memory-Auszuege die du im Workspace ablegen willst

## Empfohlene Struktur

```
_user-overrides/
  doktrin.md          # Doktrin-Overrides die laenger sind
  server.md           # Server-Doku (Pfade, NICHT Credentials)
  projekt-spezifika.md
  beispiele.md
  meine-modi/         # Custom-Modi
    spaeher.md
    marketing.md
```

## Referenz aus CLAUDE.user.md

Du kannst aus `CLAUDE.user.md` auf Files in diesem Verzeichnis verweisen:

```markdown
## Server / Infrastruktur

Siehe `_user-overrides/server.md`.
```

Der Agent liest beide Files.

## Niemals hier

- Credentials (API-Keys, Passwords)
- Geleakte Email-Texte / private Konversationen
- Daten unter NDA / interne Firmen-Geheimnisse

Workspace-Root (inkl. `_user-overrides/`) ist oft Teil eines git-Repos —
ein Leak waere unwiderruflich.
