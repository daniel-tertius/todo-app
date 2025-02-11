#!/bin/bash

repo_root=$(git rev-parse --show-toplevel)
cd $repo_root

# Source the file containing the functions
source ./scripts/functions.sh
echo_prefix="${yellow}[${magenta}SCRIPT${yellow}]${clear}"

# ----------------------------------------------------------------
# DO PREPARATIONS: npm i, npm run build, npx cap sync...
# ----------------------------------------------------------------
echo -e "${echo_prefix} Checking that dependencies are up to date"
npm i || {
    echo -e "${red}[ERROR] 'npm i' failed${clear}"
    exit 1
}

echo -e "${echo_prefix} Building Svelte code...  ${clear}"
npm run build || {
    echo -e "${red}[ERROR] 'npm run build' failed${clear}"
    exit 1
}

echo -e "${echo_prefix} Syncronising static svelte files with app assets"
npx cap sync || {
    echo -e "${red}[ERROR] 'npx cap sync' failed${clear}"
    exit 1
}

# ----------------------------------------------------------------
# GENERATE DEBUG APK FILE
# ----------------------------------------------------------------
echo -e "${echo_prefix} Building debug android APK file"
cd android
./gradlew assembleDebug || {
    echo -e "${red}[ERROR] './gradlew assembleDebug' failed${clear}"
    exit 1
}
cd -

mkdir -p app-output
echo -e "${echo_prefix} Copying 'app-debug.apk' to root"
if [ -f app-output/app-debug.apk ]; then
    rm app-output/app-debug.apk
fi
cp android/app/build/outputs/apk/debug/app-debug.apk app-output/app-debug.apk

# ----------------------------------------------------------------
# GENERATE SIGNED RELEASE APK FILE
# ----------------------------------------------------------------
echo -e "${echo_prefix} Building signed android APK file"
npx cap build android --androidreleasetype "APK" --signing-type "apksigner" || {
    echo -e "${red}[ERROR] 'npx cap build android' failed${clear}"
    exit 1
}

echo -e "${echo_prefix} Copying 'app-release-signed.apk' to root"
if [ -f app-output/app-release-signed.apk ]; then
    rm app-output/app-release-signed.apk
fi
cp android/app/build/outputs/apk/release/app-release-signed.apk app-output/app-release-signed.apk

# ----------------------------------------------------------------
# GENERATE SIGNED RELEASE AAB FILE
# ----------------------------------------------------------------
echo -e "${echo_prefix} Building signed android AAB file"
npx cap build android --androidreleasetype "AAB" --signing-type "jarsigner" || {
    echo -e "${red}[ERROR] 'npx cap build android' failed${clear}"
    exit 1
}

echo -e "${echo_prefix} Copying 'app-release-signed.aab' to root"
if [ -f app-output/unaffi-${env}.aab ]; then
    rm app-output/unaffi-${env}.aab
fi
cp android/app/build/outputs/bundle/release/app-release-signed.aab app-output/app-release-signed.aab

echo -e "${green}Script Successfully executed…${clear}"
