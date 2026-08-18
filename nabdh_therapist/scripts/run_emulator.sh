#!/usr/bin/env bash
# تشغيل تطبيق الأخصائي على محاكي Android بانتظار اكتمال الإقلاع
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

AVD="${1:-Medium_Phone_API_36.1}"
MAX_BOOT_SEC="${2:-180}"

echo "▶ إيقاف adb القديم..."
adb kill-server >/dev/null 2>&1 || true
adb start-server

if ! adb devices | grep -q 'emulator.*device'; then
  echo "▶ تشغيل المحاكي: $AVD (قد يستغرق 1–2 دقيقة)..."
  nohup "$ANDROID_HOME/emulator/emulator" -avd "$AVD" -gpu swiftshader_indirect >/tmp/nabdh-emulator.log 2>&1 &
  EMU_PID=$!
  echo "   PID=$EMU_PID — السجل: /tmp/nabdh-emulator.log"
fi

echo "▶ انتظار اتصال adb..."
adb wait-for-device

echo "▶ انتظار اكتمال الإقلاع..."
elapsed=0
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
  sleep 2
  elapsed=$((elapsed + 2))
  if [ "$elapsed" -ge "$MAX_BOOT_SEC" ]; then
    echo "✗ انتهت المهلة — المحاكي لم يكتمل. راجع: tail -50 /tmp/nabdh-emulator.log"
    exit 1
  fi
  printf "   ... %ss\r" "$elapsed"
done
echo ""
sleep 3

adb devices
flutter devices

DEVICE_ID="$(adb devices | awk '/^emulator-.*device$/{print $1; exit}')"
if [ -z "$DEVICE_ID" ]; then
  echo "✗ لم يُعثر على محاكي متصل. شغّله من Android Studio ثم أعد المحاولة."
  exit 1
fi

echo "▶ تشغيل nabdh_therapist على $DEVICE_ID ..."
cd "$ROOT"
flutter run -d "$DEVICE_ID" --device-timeout 120
