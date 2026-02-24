#!/bin/bash
# Build and run Calculator on Android emulator
set -e

ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@17}"
ADB="$ANDROID_HOME/platform-tools/adb"
EMULATOR="$ANDROID_HOME/emulator/emulator"

AVD=$("$EMULATOR" -list-avds 2>/dev/null | head -1)
if [ -z "$AVD" ]; then
    echo "Error: No Android AVD found. Create one first."
    exit 1
fi

echo "=== Starting Android Emulator ($AVD) ==="
"$EMULATOR" -avd "$AVD" -no-audio &
EMULATOR_PID=$!

echo "Waiting for emulator to boot..."
"$ADB" wait-for-device
while [ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
    sleep 2
done
echo "Emulator booted!"

echo "=== Building Calculator Android ==="
cd "$(dirname "$0")/android"
./gradlew installDebug

echo "=== Launching app ==="
"$ADB" shell am start -n com.example.calculator/.MainActivity
echo "Calculator is running on Android!"
wait $EMULATOR_PID
