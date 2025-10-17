#!/bin/sh
# fselect — unified fuzzy finder wrapper for OpenBSD using fzy(1)
# Enhanced with preview support (press Enter to preview or edit)
# fzysl preview or fzysl edit
# POSIX-compatible and OpenBSD-safe
# Requires: fzy, find, less, vi, pkg_info (all in base + pkg_add fzy)

set -euf

cmd="${1:-file}"

if ! command -v fzy >/dev/null 2>&1; then
echo "fzysl: fzy not installed. Install with: doas pkg_add fzy" >&2
exit 1
fi

# --- Helper: safe file preview ---
preview_file() {
f="$1"
echo "------------------------------------------------------------"
echo "File: $f"
echo "Type: $(file "$f" 2>/dev/null)"
echo "Size: $(stat -f %z "$f" 2>/dev/null) bytes"
echo "------------------------------------------------------------"
head -n 69 "$f" 2>/dev/null || echo "[binary or unreadable]"
echo "------------------------------------------------------------"
printf "Open in vim? [y/N]: "
read ans || exit 0
[ "$ans" = "y" ] && vim "$f"
}

# --- Command handlers ---
case "$cmd" in
file)
find . -type f 2>/dev/null | fzy
;;
dir)
find . -type d 2>/dev/null | fzy
;;
conf)
find ~/.suckless -type f 2>/dev/null | fzy
;;
pkg)
pkg_info | fzy
;;
log)
find /var/log -type f 2>/dev/null | fzy
;;
exec)
IFS=:
for d in $PATH; do
find "$d" -type f -perm +111 2>/dev/null
done | fzy
;;
src)
find ~/.suckless -type f \( -name "*.c" -o -name "*.h" -o -name "*.sh" \) 2>/dev/null | fzy
;;
any)
find / -type f 2>/dev/null | fzy
;;
edit)
sel=$(find . -type f 2>/dev/null | fzy) || exit 1
[ -n "$sel" ] && preview_file "$sel"
;;
tail)
sel=$(find /var/log -type f 2>/dev/null | fzy) || exit 1
[ -n "$sel" ] && tail -f "$sel"
;;
preview)
sel=$(find . -type f 2>/dev/null | fzy) || exit 1
[ -n "$sel" ] && preview_file "$sel"
;;
*)
echo "Usage: fzysl {file|dir|conf|pkg|log|exec|src|any|edit|tail|preview}" >&2
exit 1
;;
esac