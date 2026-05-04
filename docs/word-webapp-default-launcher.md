# Configure `.docx` to Open with Word Online (Omarchy / Arch)

## Goal

Make `.docx` files open the Word webapp via your existing `Word.desktop`.

> Limitation: Word Online **cannot directly open local files**. It will open the webapp; the file must be in OneDrive to be opened there.

---

## Option 1 — Basic (recommended)

`.docx → open Word Online`

### 1. Edit `Word.desktop`

```bash
nano ~/.local/share/applications/Word.desktop
```

```ini
[Desktop Entry]
Version=1.0
Name=Word
Comment=Open Word Online
Exec=omarchy-launch-webapp https://word.cloud.microsoft/
Terminal=false
Type=Application
Icon=/home/her/.local/share/applications/icons/Word.png
StartupNotify=true
MimeType=application/vnd.openxmlformats-officedocument.wordprocessingml.document;
Categories=Office;
```

---

### 2. Update desktop database

```bash
sudo pacman -S desktop-file-utils   # if needed
update-desktop-database ~/.local/share/applications
```

---

### 3. Set as default for `.docx`

```bash
xdg-mime default Word.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document
```

---

### 4. Verify

```bash
xdg-mime query default application/vnd.openxmlformats-officedocument.wordprocessingml.document
```

Expected:

```txt
Word.desktop
```

---

### 5. Test

```bash
xdg-open ~/Downloads/file.docx
```

✔ Result:

```txt
Opens Word Online in Chromium
```

---

## Option 2 — Script (copy to OneDrive first)

`.docx → copy → open Word Online`

### 1. Create script

```bash
mkdir -p ~/.local/bin
nano ~/.local/bin/open-docx-word-online
```

```bash
#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"

if [ -z "$FILE" ]; then
  omarchy-launch-webapp https://word.cloud.microsoft/
  exit 0
fi

ONEDRIVE_DIR="$HOME/OneDrive/WordOnline"
mkdir -p "$ONEDRIVE_DIR"

cp "$FILE" "$ONEDRIVE_DIR/$(basename "$FILE")"

omarchy-launch-webapp https://word.cloud.microsoft/
```

```bash
chmod +x ~/.local/bin/open-docx-word-online
```

---

### 2. Update `Word.desktop`

```ini
Exec=/home/her/.local/bin/open-docx-word-online %f
```

---

### 3. Re-run

```bash
update-desktop-database ~/.local/share/applications
xdg-mime default Word.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document
```

---

### 4. Test

```bash
xdg-open ~/Downloads/file.docx
```

✔ Result:

```txt
File copied to ~/OneDrive/WordOnline
Word Online opens
```

---

## Troubleshooting

### Check MIME type

```bash
xdg-mime query filetype file.docx
```

Expected:

```txt
application/vnd.openxmlformats-officedocument.wordprocessingml.document
```

If wrong:

```bash
sudo pacman -S perl-file-mimeinfo
```

---

### Validate desktop file

```bash
desktop-file-validate ~/.local/share/applications/Word.desktop
```

---

## Final Summary

| Setup    | Behavior                        |
| -------- | ------------------------------- |
| Option 1 | Opens Word Online               |
| Option 2 | Copies file + opens Word Online |

> Full automation (open exact file in Word Online) requires OneDrive API (Graph API).
