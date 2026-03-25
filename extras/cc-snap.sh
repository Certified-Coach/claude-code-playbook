#!/bin/bash
# cc-snap — Desktop screenshot for Claude Code.
#
# Captures the screen and saves to ~/screenshot.png so Claude can read
# it with the Read tool. Auto-detects platform: macOS, WSL, or Windows.
#
# Usage:
#   cc-snap              # full primary screen
#   cc-snap -w           # focused window only (macOS + WSL)
#   cc-snap -o /tmp/x.png  # custom output path
#
# Install (pick one):
#   a) Copy to PATH:  cp cc-snap.sh ~/.local/bin/cc-snap && chmod +x ~/.local/bin/cc-snap
#   b) Source in bashrc:  echo 'source ~/claude-code-playbook/extras/cc-snap.sh' >> ~/.bashrc
#
# How Claude uses it — add to your CLAUDE.md trigger table:
#   | `cc-snap` | Capture screen | `cc-snap` → read `~/screenshot.png` |
#
# Platform support:
#   macOS        — uses screencapture (built-in)
#   WSL          — uses powershell.exe to capture Windows desktop
#   Windows      — uses powershell.exe directly (Git Bash, MSYS2, etc.)
#   Linux (X11)  — uses import (ImageMagick) or scrot
#
# Requirements:
#   macOS:   none (screencapture is built-in)
#   WSL:     powershell.exe accessible (default on WSL)
#   Windows: powershell.exe accessible (default on Git Bash)
#   Linux:   imagemagick (import) or scrot

set -euo pipefail

MODE="full"
OUTPUT="$HOME/screenshot.png"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--window) MODE="window"; shift ;;
    -o|--output)  OUTPUT="$2"; shift 2 ;;
    full)         MODE="full"; shift ;;
    -h|--help)
      echo "Usage: cc-snap [-w] [-o path] [full]"
      echo "  -w, --window   Capture focused window only"
      echo "  -o, --output   Output path (default: ~/screenshot.png)"
      echo "  full           Capture full primary screen (default)"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

mkdir -p "$(dirname "$OUTPUT")"

# ── macOS ──────────────────────────────────────────────────────
if [[ "$OSTYPE" == darwin* ]]; then
  if [[ "$MODE" == "window" ]]; then
    screencapture -w -x "$OUTPUT"
  else
    screencapture -x "$OUTPUT"
  fi
  echo "$OUTPUT"
  exit 0
fi

# ── WSL or Windows (Git Bash / MSYS2) ─────────────────────────
if command -v powershell.exe &>/dev/null; then
  TEMP_PATH='C:\Temp\cc-snap.png'

  # Ensure C:\Temp exists
  powershell.exe -NoProfile -NoLogo -Command "if(-not(Test-Path 'C:\Temp')){New-Item -ItemType Directory -Path 'C:\Temp'|Out-Null}" 2>/dev/null

  if [[ "$MODE" == "window" ]]; then
    powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "
      Add-Type -AssemblyName System.Drawing
      Add-Type 'using System;using System.Runtime.InteropServices;public class W32{[DllImport(\"user32.dll\")]public static extern IntPtr GetForegroundWindow();[DllImport(\"user32.dll\")]public static extern bool GetWindowRect(IntPtr h,out RECT r);[StructLayout(LayoutKind.Sequential)]public struct RECT{public int L,T,R,B;}}' -Language CSharp
      \$h=[W32]::GetForegroundWindow()
      \$r=New-Object W32+RECT
      [W32]::GetWindowRect(\$h,[ref]\$r)|Out-Null
      \$w=\$r.R-\$r.L; \$ht=\$r.B-\$r.T
      if (\$w -le 0 -or \$ht -le 0) { Write-Error 'No focused window found'; exit 1 }
      \$b=New-Object Drawing.Bitmap(\$w,\$ht)
      \$g=[Drawing.Graphics]::FromImage(\$b)
      \$g.CopyFromScreen(\$r.L,\$r.T,0,0,\$b.Size)
      \$g.Dispose()
      \$b.Save('$TEMP_PATH')
      \$b.Dispose()
    " 2>/dev/null
  else
    powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "
      Add-Type -AssemblyName System.Windows.Forms,System.Drawing
      \$s=[Windows.Forms.Screen]::PrimaryScreen.Bounds
      \$b=New-Object Drawing.Bitmap(\$s.Width,\$s.Height)
      \$g=[Drawing.Graphics]::FromImage(\$b)
      \$g.CopyFromScreen(\$s.Location,[Drawing.Point]::Empty,\$s.Size)
      \$g.Dispose()
      \$b.Save('$TEMP_PATH')
      \$b.Dispose()
    " 2>/dev/null
  fi

  # Copy from Windows temp to the output path
  if [[ -d /mnt/c ]]; then
    # WSL — access via /mnt/c
    cp /mnt/c/Temp/cc-snap.png "$OUTPUT" || { echo "Failed to copy screenshot" >&2; exit 1; }
  else
    # Native Windows (Git Bash / MSYS2) — access via /c
    cp /c/Temp/cc-snap.png "$OUTPUT" 2>/dev/null || cp "C:/Temp/cc-snap.png" "$OUTPUT" || { echo "Failed to copy screenshot" >&2; exit 1; }
  fi

  echo "$OUTPUT"
  exit 0
fi

# ── Linux (X11) ───────────────────────────────────────────────
if command -v import &>/dev/null; then
  # ImageMagick
  if [[ "$MODE" == "window" ]]; then
    import "$OUTPUT"
  else
    import -window root "$OUTPUT"
  fi
  echo "$OUTPUT"
  exit 0
fi

if command -v scrot &>/dev/null; then
  if [[ "$MODE" == "window" ]]; then
    scrot -u "$OUTPUT"
  else
    scrot "$OUTPUT"
  fi
  echo "$OUTPUT"
  exit 0
fi

echo "No screenshot tool found. Install one of: screencapture (macOS), powershell.exe (Windows/WSL), imagemagick, or scrot (Linux)." >&2
exit 1
