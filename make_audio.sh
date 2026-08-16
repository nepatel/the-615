#!/usr/bin/env bash
# The 6:15 — audio companion generator. Self-contained and idempotent.
# Usage: ./make_audio.sh script.txt output.mp3
set -euo pipefail
SCRIPT="${1:?need script file}"; OUT="${2:?need output mp3}"
VDIR="$HOME/.piper-voices"
VOICE="$VDIR/en_US-lessac-medium.onnx"
REL="https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-en_US-lessac-medium.tar.bz2"

# 1. Ensure the voice model exists; fetch only if missing (resilient to fresh env).
if [ ! -f "$VOICE" ]; then
  echo "voice model missing — fetching once..."
  mkdir -p "$VDIR" && cd "$VDIR"
  curl -sL -o v.tar.bz2 "$REL"
  tar xjf v.tar.bz2 --strip-components=1 vits-piper-en_US-lessac-medium/en_US-lessac-medium.onnx vits-piper-en_US-lessac-medium/en_US-lessac-medium.onnx.json
  rm -f v.tar.bz2; cd - >/dev/null
fi

# 2. Safety-net normalization: catch stray symbols the audio script missed.
python3 - "$SCRIPT" > .audio_clean.txt <<'PY'
import re,sys
t=open(sys.argv[1]).read()
t=re.sub(r'\$\s?(\d+(?:\.\d+)?)',r'\1 dollars',t)
t=re.sub(r'(\d+(?:\.\d+)?)\s?%',r'\1 percent',t)
t=t.replace('&','and').replace('—',', ').replace('–','-')
print(t)
PY

# 3. Generate and compress.
python3 -m piper --model "$VOICE" --output-file .audio_raw.wav < .audio_clean.txt
ffmpeg -y -i .audio_raw.wav -b:a 96k "$OUT" -loglevel error
rm -f .audio_raw.wav .audio_clean.txt
echo "done: $OUT ($(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")s)"
