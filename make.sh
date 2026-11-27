#!/usr/bin/env bash
# Fetches every ayah of Mishary Alafasy (everyayah.com, 128 kbps) and compresses it to HE-AAC 16 kbps mono
# (the owner listened to samples and chose it, 2026-11-27: «الاقوى مقبول جدا») into a16/SSSAAA.m4a.
# Ayat already done are skipped.
set -uo pipefail
mkdir -p a16 src
one() {
  id=$1
  [ -s "a16/$id.m4a" ] && return 0
  curl -sf --retry 4 --retry-delay 2 -o "src/$id.mp3" "https://everyayah.com/data/Alafasy_128kbps/$id.mp3" || { echo "miss $id"; return 0; }
  afconvert -f m4af -d aach -b 16000 -c 1 "src/$id.mp3" "a16/$id.m4a" || echo "fail $id"
  rm -f "src/$id.mp3"
}
export -f one
xargs -P 6 -I{} bash -c 'one {}' < ids.txt
echo "files: $(ls a16 | wc -l)"
du -sh a16
afinfo "a16/002255.m4a" | grep -E "Data format|bit rate|estimated duration" || true
