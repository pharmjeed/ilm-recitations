#!/usr/bin/env bash
# Fetches every ayah of Mishary Alafasy (everyayah.com, 128 kbps) and compresses it to HE-AAC 24 kbps mono
# (strong compression chosen by the owner, 2026-11-27) into a24/SSSAAA.m4a. Ayat already done are skipped.
set -uo pipefail
mkdir -p a24 src
one() {
  id=$1
  [ -s "a24/$id.m4a" ] && return 0
  curl -sf --retry 4 --retry-delay 2 -o "src/$id.mp3" "https://everyayah.com/data/Alafasy_128kbps/$id.mp3" || { echo "miss $id"; return 0; }
  afconvert -f m4af -d aach -b 24000 -c 1 "src/$id.mp3" "a24/$id.m4a" 2>/dev/null \
    || afconvert -f m4af -d 'aach@44100' -b 24000 -c 1 "src/$id.mp3" "a24/$id.m4a" 2>/dev/null \
    || afconvert -f m4af -d 'aac@22050' -b 24000 -c 1 "src/$id.mp3" "a24/$id.m4a" \
    || echo "fail $id"
  rm -f "src/$id.mp3"
}
export -f one
xargs -P 6 -I{} bash -c 'one {}' < ids.txt
echo "files: $(ls a24 | wc -l)"
du -sh a24
afinfo "a24/002255.m4a" | grep -E "Data format|bit rate|estimated duration" || true
