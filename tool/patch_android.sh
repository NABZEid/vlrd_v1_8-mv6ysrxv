#!/usr/bin/env bash
# Dijalankan otomatis oleh workflow setelah folder android dibuat.
set -e
M=android/app/src/main/AndroidManifest.xml
python3 - "$M" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
perm = 'android.permission.INTERNET'  # untuk jembatan lokal 127.0.0.1 ke Bloader
if perm not in s:
    s = s.replace('<application', '    <uses-permission android:name="%s"/>\n    <application' % perm, 1)
open(p, 'w', encoding='utf-8').write(s)
PY

# Ikon aplikasi memakai logo yang sudah ada (assets/logo.png),
# diletakkan di atas latar navy supaya tidak transparan/hitam di launcher.
R=android/app/src/main/res
BG='#050B1A'
for pair in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  d=${pair%%:*}; z=${pair##*:}
  mkdir -p "$R/mipmap-$d"
  out="$R/mipmap-$d/ic_launcher.png"
  if command -v convert >/dev/null 2>&1; then
    inner=$((z * 82 / 100))
    convert -size ${z}x${z} xc:"$BG" \( assets/logo.png -resize ${inner}x${inner} \) \
      -gravity center -composite "$out"
  else
    python3 - "$z" "$out" <<'PY'
import sys
from PIL import Image
z = int(sys.argv[1]); out = sys.argv[2]
bg = Image.new('RGBA', (z, z), (5, 11, 26, 255))
lg = Image.open('assets/logo.png').convert('RGBA')
n = int(z * 0.82)
lg = lg.resize((n, n), Image.LANCZOS)
bg.alpha_composite(lg, ((z - n) // 2, (z - n) // 2))
bg.convert('RGB').save(out)
PY
  fi
done
echo "patch_android selesai"
