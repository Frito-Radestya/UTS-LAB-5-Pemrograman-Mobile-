#!/bin/bash
set -e

echo "=== Menyiapkan Flutter SDK untuk Vercel ==="
if [ -d "flutter" ]; then
  cd flutter
  git pull
  cd ..
else
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
fi

export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Memeriksa Flutter ==="
flutter --version

echo "=== Mengunduh Dependencies ==="
flutter pub get

echo "=== Membangun Flutter Web Release ==="
flutter build web --release

echo "=== Selesai! Berkas siap di build/web ==="
