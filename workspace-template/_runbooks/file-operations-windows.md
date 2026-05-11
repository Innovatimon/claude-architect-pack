# Runbook: File-Operations unter Windows
> Klassifikation: L2

> **Trigger:** "Permission denied bei mv", "robocopy", "Datei nicht verschiebbar", "IDE-Lock", "Move-Item geht nicht"

## Problem-Kategorien

### 1. Datei in Verwendung (IDE-Lock)

Windows lockt Files die ein Editor / eine IDE offen hat.

**Symptom:** `Move-Item`, `Remove-Item`, `Rename-Item` schlaegt fehl mit
"Used by another process" oder "Permission denied".

**Fix:**
1. IDE/Editor schliessen die das File offen hat
2. Falls VS Code: `code.exe --kill`-Trick oder einfach Fenster zu
3. Antigravity-/Cursor-/IntelliJ-Lock: Workspace-Reload (Ctrl+Shift+P -> "Reload Window")
4. Falls all-else-fails: Reboot

### 2. Pfad-Laengen-Limit (260 Zeichen)

Windows hat Default-Pfad-Limit von 260 Zeichen.

**Symptom:** "Path too long" Error.

**Fix:**
- Workspace naeher an Root (z.B. `C:\code\` statt `C:\Users\Long Name\Documents\...`)
- Long-Path-Support aktivieren (Group Policy):
  ```
  Computer Configuration > Administrative Templates > System > Filesystem > Enable Win32 long paths
  ```
- Git Long-Path:
  ```bash
  git config --global core.longpaths true
  ```

### 3. Sonderzeichen / Spaces

Pfade mit Spaces oder Umlauten brauchen Quoting.

**Bash:** `"<Pfad mit Spaces>"`
**PowerShell:** `"<Pfad mit Spaces>"` ODER `'<Pfad mit Spaces>'`
**cmd.exe:** `"<Pfad mit Spaces>"` (cmd-Quoting unzuverlaessig)

### 4. Permission-Probleme

**Symptom:** "Access is denied" trotz Admin.

**Fix:**
- Pruefe Owner: `Get-Acl <pfad> | Format-List`
- Reset Permissions:
  ```powershell
  icacls "<pfad>" /reset /T /C /L /Q
  ```
- Antivirus / Defender Block: Quarantaene pruefen

## Werkzeuge

### Move-Item (PowerShell)

```powershell
Move-Item -Path "<source>" -Destination "<dest>" -Force
```

Bei Recursive:
```powershell
Move-Item -Path "<source>\*" -Destination "<dest>\" -Force -Recurse
```

### robocopy (fuer grosse / problematische Operationen)

```cmd
robocopy "<source>" "<dest>" /E /MOV /R:3 /W:5
```

- `/E` = inkl. leere Unterverzeichnisse
- `/MOV` = move (loescht Source nach Copy)
- `/R:3` = 3 Retries
- `/W:5` = 5 Sekunden zwischen Retries
- `/MIR` = mirror (Source = Target, Vorsicht!)

### Remove-Item (Force)

```powershell
Remove-Item -Path "<pfad>" -Force -Recurse
```

Bei Locks ueberraschend oft erfolgreich, weil `-Force` Read-Only-Attribute uebergeht.

### Git-Operationen unter Windows

**Line-Endings:**
```bash
git config --global core.autocrlf input    # bei mixed teams
git config --global core.autocrlf false    # bei reinen Windows-Repos
```

**Case-Sensitivity:**
Windows-Filesystem ist case-insensitive aber case-preserving. Git kann
auf Linux Files mit `File.md` und `file.md` parallel haben — auf Windows
wird einer ueberschrieben. Konflikt fixen:
```bash
git rm --cached File.md
git mv file.md FILE.md  # exakte Schreibweise
```

## Bekannte Fallen

### Antigravity-Editor revertet Aenderungen

Manche Editor-Sandboxes haben Auto-Revert-Hooks. Wenn `rm` / `Move-Item`
"erfolgreich" wirkt aber das File ist nach 2 Sekunden wieder da:

1. Editor-Sync deaktivieren (UI-spezifisch)
2. Alternative Tool nutzen: `Remove-Item` statt `rm`, `robocopy /MOV` statt `Move-Item`
3. Aenderung in Terminal AUSSERHALB der Editor-Sandbox

### `mv` auf Bash (Git Bash) unter Windows

Git-Bash hat eine `mv`-Emulation, die manchmal failt wo PowerShell-`Move-Item` funktioniert.
Bei Problemen: PowerShell direkt nutzen oder via `powershell.exe -Command`.

### `cp -r` vs `Copy-Item -Recurse`

Beide funktionieren, aber bei sehr grossen Verzeichnissen
ist `robocopy` 5-10x schneller.

## Verifizieren

- [ ] Operation erfolgreich (kein Permission-Error)
- [ ] Source nicht mehr da (bei move)
- [ ] Target hat alle erwarteten Files
- [ ] Git status sauber (kein versehentlicher Tracking-Konflikt)

## Learnings

### IDE-Locks sind die haeufigste Ursache
80% aller "Permission denied" auf Windows kommt davon dass eine IDE das File offen hat. Erster Schritt immer: pruefe ob ein Editor das File offen hat.

### Long-Path-Support einmal aktivieren, Ruhe haben
Workspaces mit tiefer Verschachtelung (z.B. `Projekte/E-ComV2/Shops/X/_archive/2026-05-...-berichte/welle-X-Y-zwischenbericht.md`) treffen schnell das 260-Zeichen-Limit. Long-Path-Support einmal aktivieren, dann ist Ruhe.

### robocopy ist unschlagbar bei Grossen Operationen
Fuer Move-Operationen ueber 100+ Files / 1+ GB ist `robocopy /MOV` deutlich robuster als `Move-Item` oder `mv`.
